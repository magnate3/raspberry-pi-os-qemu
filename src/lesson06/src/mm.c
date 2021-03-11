#include "mm.h"
#include "arm/mmu.h"

/* 
	minimalist page allocation 
*/
static unsigned short mem_map [ PAGING_PAGES ] = {0,};

unsigned long allocate_kernel_page() {
	unsigned long page = get_free_page();
	if (page == 0) {
		return 0;
	}
	return page + VA_START;
}

unsigned long allocate_user_page(struct task_struct *task, unsigned long va) {
	unsigned long page = get_free_page();
	if (page == 0) {
		return 0;
	}
	map_page(task, va, page);
	return page + VA_START;
}

unsigned long get_free_page()
{
	for (int i = 0; i < PAGING_PAGES; i++){
		if (mem_map[i] == 0){
			mem_map[i] = 1;
			unsigned long page = LOW_MEMORY + i*PAGE_SIZE;
			memzero(page + VA_START, PAGE_SIZE);
			return page;
		}
	}
	return 0;
}

void free_page(unsigned long p){
	mem_map[(p - LOW_MEMORY) / PAGE_SIZE] = 0;
}

/*
	Virtual memory implementation
*/

/* set a pte (at the bottom of a pgtable tree), 
   so that @va is mapped to @pa. @pte: the 0-th pte of that pgtable */
void map_table_entry(unsigned long *pte, unsigned long va, unsigned long pa) {
	unsigned long index = va >> PAGE_SHIFT;
	index = index & (PTRS_PER_TABLE - 1);
	unsigned long entry = pa | MMU_PTE_FLAGS; 
	pte[index] = entry;
}

/* Extract table index from the virtual address and prepares a descriptor 
	in the parent table that points to the child table.

   @table: a (virt) pointer to the parent page table. This page table is assumed 
   	to be already allocated, but might contain empty entries.
   @shift: indicate where to find the index bits in a virtual address corresponding 
   	to the the target pgtable level. See project description for details.
   @va: the virt address of the page to be mapped
   @new_table [out]: 1 means a new pgtable is allocated; 0 otherwise

   Return: the phys addr of the next pgtable. 
*/
unsigned long map_table(unsigned long *table, unsigned long shift, unsigned long va, int* new_table) {
	unsigned long index = va >> shift;
	index = index & (PTRS_PER_TABLE - 1);
	if (!table[index]){ /* next level pgtable absent. alloate a new page & install. */
		*new_table = 1;
		unsigned long next_level_table = get_free_page();
		unsigned long entry = next_level_table | MM_TYPE_PAGE_TABLE;
		table[index] = entry;
		return next_level_table;
	} else {
		*new_table = 0;
	}
	return table[index] & PAGE_MASK;
}

/* map a page to the given @task at its virtual address @va. 
   @page: the phys addr of the page start. 
   Descend in the task's pgtable tree and alloate any absent pgtables on the way.
   */
void map_page(struct task_struct *task, unsigned long va, unsigned long page){
	unsigned long pgd;
	if (!task->mm.pgd) { /* start from the task's top-level pgtable. allocate if absent */
		task->mm.pgd = get_free_page();
		task->mm.kernel_pages[++task->mm.kernel_pages_count] = task->mm.pgd;
	}
	pgd = task->mm.pgd;
	int new_table; 
	/* move to the next level pgtable. allocate one if absent */
	unsigned long pud = map_table((unsigned long *)(pgd + VA_START), PGD_SHIFT, va, &new_table);
	if (new_table) { /* we've allocated a new kernel page. take it into account for future reclaim */
		task->mm.kernel_pages[++task->mm.kernel_pages_count] = pud;
	}
	/* next level ... */
	unsigned long pmd = map_table((unsigned long *)(pud + VA_START) , PUD_SHIFT, va, &new_table);
	if (new_table) {
		task->mm.kernel_pages[++task->mm.kernel_pages_count] = pmd;
	}
	/* next level ... */
	unsigned long pte = map_table((unsigned long *)(pmd + VA_START), PMD_SHIFT, va, &new_table);
	if (new_table) {
		task->mm.kernel_pages[++task->mm.kernel_pages_count] = pte;
	}
	/* reached the bottom level of pgtable tree */
	map_table_entry((unsigned long *)(pte + VA_START), va, page);
	struct user_page p = {page, va};
	task->mm.user_pages[task->mm.user_pages_count++] = p;
}

/* duplicate the contents of the @current task's user pages to the @dst task */
int copy_virt_memory(struct task_struct *dst) {
	struct task_struct* src = current;
	for (int i = 0; i < src->mm.user_pages_count; i++) {
		unsigned long kernel_va = allocate_user_page(dst, src->mm.user_pages[i].virt_addr);
		if( kernel_va == 0) {
			return -1;
		}
		memcpy(src->mm.user_pages[i].virt_addr, kernel_va, PAGE_SIZE);
	}
	return 0;
}

static int ind = 1;

int do_mem_abort(unsigned long addr, unsigned long esr) {
	unsigned long dfs = (esr & 0b111111);
	if ((dfs & 0b111100) == 0b100) {
		unsigned long page = get_free_page();
		if (page == 0) {
			return -1;
		}
		map_page(current, addr & PAGE_MASK, page);
		ind++;
		if (ind > 2){
			return -1;
		}
		return 0;
	}
	return -1;
}
