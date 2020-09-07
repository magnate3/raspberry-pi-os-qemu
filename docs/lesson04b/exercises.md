## Exercises

1. Increase the rate of context switch to 10 Hz

2. Tracing context switch. Whenever a context switch happens, record the timestamp and the IDs of tasks that are switching in and out. After 200 of context switches, print out a list of switch records. Why is it a bad idea to print out the information of a context switch as it happens? 

  

## Deliverable

A code tarball implementing (1) above. 

A code tarball implementing (2) above. 

  <!---- 1. Add `printf` to all main kernel functions to output information about the current memory and processor state. Make sure that the state diagrams, that I've added to the end of the RPi OS part of this lesson, are correct.  (You do not necessarily need to output all state each time, but as soon as some major event happens you can output current stack pointer, or address of the object that has just been allocated, or whatever you consider necessary. Think about some mechanism to prevent information overflow) --->

<!---- 1. Introduce a way to assign priority to the tasks. Make sure that a task with higher priority gets more processor time that the one with lower priority. 1. Allow user processes to use FP/SIMD registers. Those registers should be saved in the task context and swapped during the context switch. --->

   
