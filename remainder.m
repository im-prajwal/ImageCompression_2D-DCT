function remOut = remainder(Nr,Dr)
%User-Defined function to compute remainder
%Input Arguments: 
%    1st Argument = Numerator(Dividend) 
%    2nd Argument = Denoinator(Divisor)
%Output: Remainder of the division

Q = floor(Nr/Dr);
remOut = Nr-(Q*Dr);

end