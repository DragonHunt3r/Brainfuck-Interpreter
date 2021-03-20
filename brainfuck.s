# This interpreter validates the following:
#  - Every opening bracket is paired with a matching closing brackets (and vice versa)
#  - The cursor will always point to a valid index in the array
#
# It will not detect, prevent or stop infinite loops
# It will skip over non-command characters
#
# TODO: Variable cell size
#
# r12 nested count
# r13 array pointer
# r14 cursor
# r15 character pointer

.data
  array_size: .long 30000
  errorMem: .asciz "Could not allocate enough memory\n"
  errorBounds: .asciz "Cursor position out of bounds \n"
  errorBrackets: .asciz "Brackets do not match up\n"

.global brainfuck

# Could not allocate memory
nomem:
  movq $0, %rax
  movq $errorMem, %rdi
  call printf
  movq $1, %rax
  jmp end0

# Cursor goes out of bounds
bounds:
  movq $0, %rax
  movq $errorBounds, %rdi
  call printf
  movq $2, %rax
  jmp end0

# Brackets do not match up
brackets:
  movq $0, %rax
  movq $errorBrackets, %rdi
  call printf
  movq $1, %rax
  jmp end0

# > (62) subroutine
# Increment pointer
gt:
  cmpq $0, %r12
  jg loop
  incq %r14
  cmpq $array_size, %r14
  je bounds
  jmp loop

# < (60) subroutine
# Decrement pointer
lt:
  cmpq $0, %r12
  jg loop
  cmpq $0, %r14
  je bounds
  decq %r14
  jmp loop

# + (43) subroutine
# Increment value
pl:
  cmpq $0, %r12
  jg loop
  incb (%r13, %r14)
  jmp loop

# - (45) subroutine
# Decrement value
mi:
  cmpq $0, %r12
  jg loop
  decb (%r13, %r14)
  jmp loop

# . (46) subroutine
# Print value
pe:
  cmpq $0, %r12
  jg loop
  movq $0, %rdi
  addb (%r13, %r14), %dil
  call putchar
  jmp loop

# , (44) subroutine
# Read value
co:
  cmpq $0, %r12
  jg loop
  call getchar
  movb %al, (%r13, %r14)
  jmp loop

# [ (91) subroutine
# Jump if zero forward to the command after matching ] command
bo:
  cmpq $0, %r12
  jg bo0
  cmpb $0, (%r13, %r14)
  je bo0
  pushq %r15
  jmp loop

bo0:
  incq %r12
  # TODO: Overflow handling
  jmp loop
  

# ] (93) subroutine
# Jump if not zero back to the command after matching [ command
bc:
  cmpq $0, %r12
  jg bc1
  cmpq %rsp, %rbp
  je brackets
  cmpq $0, (%r13, %r14)
  jne bc0
  addq $8, %rsp
  jmp loop

bc0:
  popq %r15
  jmp loop0

bc1:
  decq %r12
  jmp loop
  

# int brainfuck(char *c)
# 0: Success
# 1: Memory could not be allocated
# 2: Cursor out of bounds
brainfuck:
  pushq %rbp
  pushq %r12
  pushq %r13
  pushq %r14
  pushq %r15
  movq %rsp, %rbp
  
  # Nest count
  movq $0, %r12

  # Cursor
  movq $0, %r14

  # Character pointer
  movq %rdi, %r15

  # void *calloc(size_t nitems, size_t size)
  movq $array_size, %rdi
  movq $1, %rsi
  call calloc
  cmpq $0, %rax
  je nomem
  movq %rax, %r13

  jmp loop0         # Skip the initial increment

loop:
  incq %r15

loop0:
  movb (%r15), %al

  cmpb $62, %al
  je gt
  cmpb $60, %al
  je lt
  cmpb $43, %al
  je pl
  cmpb $45, %al
  je mi
  cmpb $46, %al
  je pe
  cmpb $44, %al
  je co
  cmpb $91, %al
  je bo
  cmpb $93, %al
  je bc

  cmpb $0, %al   # Null
  je end
  
  jmp loop

end:
  cmpq %rsp, %rbp
  jne brackets
  cmpq $0, %r12
  jne brackets
  movq $0, %rax
  

end0:
  pushq %rax
  movq %r13, %rdi
  call free
  popq %rax
  movq %rbp, %rsp
  popq %r15
  popq %r14
  popq %r13
  popq %r12
  popq %rbp
  ret