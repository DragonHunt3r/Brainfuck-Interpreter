# r13 buffer pointer
# r14 file size
# r15 file descriptor

.data
  format: .asciz "Usage: %s <file>\n"
  errorOpen: .asciz "Could not open file\n"
  errorSeek: .asciz "Could not seek file position\n"
  errorTell: .asciz "Could not get file position\n"
  errorAllocate: .asciz "Could not allocate character buffer\n"
  errorRead: .asciz "Could not read file\n"
  readFlag: .asciz "r"

.global main

usage:
  movq $0, %rax
  movq $format, %rdi
  movq (%rsi), %rsi
  call printf
  jmp end

iofailopen:
  movq $0, %rax
  movq $errorOpen, %rdi
  call printf
  movq $0, %rax
  jmp readend0

iofailseek:
  movq $0, %rax
  movq $errorSeek, %rdi
  call printf
  movq $0, %rax
  jmp readend

iofailtell:
  movq $0, %rax
  movq $errorTell, %rdi
  call printf
  movq $0, %rax
  jmp readend

iofailallocate:
  movq $0, %rax
  movq $errorAllocate, %rdi
  call printf
  movq $0, %rax
  jmp readend

iofailread:
  movq $0, %rax
  movq $errorRead, %rdi
  call printf
  movq $0, %rax
  jmp readend

# char *read(char *file)
# NULL: Could not read file
# Else: Pointer to character array
read:
  pushq %rbp
  movq %rsp, %rbp
  
  subq $24, %rsp
  
  # FILE *fopen(const char *filename, const char *mode)
  movq $readFlag, %rsi
  call fopen
  cmpq $0, %rax
  je iofailopen
  movq %rax, -8(%rbp)
  
  # int fseek(FILE *stream, long int offset, int whence)
  movq -8(%rbp), %rdi
  movq $0, %rsi
  movq $2, %rdx     # SEEK_END
  call fseek
  cmp $0, %rax
  jne iofailseek

  # long int ftell(FILE *stream)
  movq -8(%rbp), %rdi
  call ftell
  cmpq $0, %rax
  jl iofailtell
  movq %rax, -16(%rbp)

  # int fseek(FILE *stream, long int offset, int whence)
  movq -8(%rbp), %rdi
  movq $0, %rsi
  movq $0, %rdx     # SEEK_SET
  call fseek
  cmp $0, %rax
  jne iofailseek
  
  # void *calloc(size_t nitems, size_t size)
  movq -16(%rbp), %rdi
  incq %rdi
  movq $1, %rsi
  call calloc
  cmp $0, %rax
  je iofailallocate
  movq %rax, -24(%rbp)

  # size_t fread(void *ptr, size_t size, size_t nmemb, FILE *stream)
  movq -24(%rbp), %rdi
  movq $1, %rsi
  movq -16(%rbp), %rdx
  movq -8(%rbp), %rcx
  call fread
  cmpq -16(%rbp), %rax
  jne iofailread
  
  # Return pointer
  movq -24(%rbp), %rax

# Read function end
# Assumes rax stores return value
readend:
  pushq %rax
  movq -8(%rbp), %rdi
  call fclose
  popq %rax

readend0:  
  movq %rbp, %rsp
  popq %rbp
  ret

readfail:
  movq $1, %rax
  jmp end

bffail:
  movq $2, %rax
  jmp end

# int main(int argc, char *argv[])
# 0: Success
# 1: File read error
# 2: Brainfuck error
main:
  pushq %rbp
  movq %rsp, %rbp
  
  subq $8, %rsp

  cmpq $2, %rdi
  jne usage

  movq 8(%rsi), %rdi
  call read
  cmpq $0, %rax
  je readfail
  
  movq %rax, -8(%rbp)
  
  movq -8(%rbp), %rdi
  call brainfuck
  cmpq $0, %rax
  je bffail
  
  movq $0, %rax

# Main function end
# Assumes rax stores exit code
end:
  pushq %rax
  movq -8(%rbp), %rdi
  call free
  popq %rax
  movq %rbp, %rsp
  popq %rbp
  ret