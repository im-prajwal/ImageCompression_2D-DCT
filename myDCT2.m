function[I] = myDCT2(i)
%Computes 2D-DCT of an m x n Matrix
%Input Argument: Input Matrix
%Output: 2D - Discrete Cosine Transformed Matrix 

m = size(i,1); n = size(i,2);   %Can also use [m n] = size(i)
I = zeros(m,n);   %Can also use I = zeros(size(i))

for p = 1:m
    for q = 1:n
        
        if p == 1
            Ap = sqrt(1/m);
        else 
            Ap = sqrt(2/m);
        end
        
        if q == 1
            Aq = sqrt(1/n);
        else 
            Aq = sqrt(2/n);
        end
               
        for x =1:m
            for y = 1:n
                I(p,q) = I(p,q) + Ap*Aq*i(x,y)*cos((pi*(2*(x-1)+1)*(p-1))/(2*m))*cos((pi*(2*(y-1)+1)*(q-1))/(2*n)); 
            end
        end
        
    end
end


end