    Program dppcon_example

!     DPPCON Example Program Text

!     Copyright 2017, Numerical Algorithms Group Ltd. http://www.nag.com

!     .. Use Statements ..
      Use lapack_interfaces, Only: dlansp, dppcon, dpptrf
      Use lapack_precision, Only: dp
!     .. Implicit None Statement ..
      Implicit None
!     .. Parameters ..
      Integer, Parameter :: nin = 5, nout = 6
!     .. Local Scalars ..
      Real (Kind=dp) :: anorm, rcond
      Integer :: i, info, j, n
      Character (1) :: uplo
!     .. Local Arrays ..
      Real (Kind=dp), Allocatable :: ap(:), work(:)
      Integer, Allocatable :: iwork(:)
!     .. Intrinsic Procedures ..
      Intrinsic :: epsilon
!     .. Executable Statements ..
      Write (nout, *) 'DPPCON Example Program Results'
!     Skip heading in data file
      Read (nin, *)
      Read (nin, *) n

      Allocate (ap(n*(n+1)/2), work(3*n), iwork(n))

!     Read A from data file

      Read (nin, *) uplo
      If (uplo=='U') Then
        Read (nin, *)((ap(i+j*(j-1)/2),j=i,n), i=1, n)
      Else If (uplo=='L') Then
        Read (nin, *)((ap(i+(2*n-j)*(j-1)/2),j=1,i), i=1, n)
      End If

!     Compute norm of A
      anorm = dlansp('1-norm', uplo, n, ap, work)

!     Factorize A
      Call dpptrf(uplo, n, ap, info)

      Write (nout, *)
      If (info==0) Then

!       Estimate condition number

        Call dppcon(uplo, n, ap, anorm, rcond, work, iwork, info)

        If (rcond>=epsilon(1.0E0_dp)) Then
          Write (nout, 100) 'Estimate of condition number =', 1.0_dp/rcond
        Else
          Write (nout, *) 'A is singular to working precision'
        End If
      Else
        Write (nout, *) 'A is not positive definite'
      End If

100   Format (1X, A, 1P, E10.2)
    End Program
