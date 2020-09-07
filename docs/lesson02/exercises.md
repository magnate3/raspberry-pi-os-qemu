## Exercises

<!--- Some questions about ARMv8 --->

<!--- Modify Regardless of starting in EL3 or EL2, go to EL1-->

1. Modify boot.S, so that your kernel switches to EL0 (instead of switching to EL1). 
2. After landing in EL0, can your kernel print out the current exception level? If so, how? If not, why? 
3. Describe in a short paragraph: what will happen if we execute an `eret` instruction at EL0? 



### Deliverable

A code tarball implementing (1) above. 

A docx or PDF file answering (2) (3) above.

