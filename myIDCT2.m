function[i] = myIDCT2(I)
%Computes 2D-IDCT of an m x n Matrix
%Input Argument: Input Matrix
%Output: 2D - Inverse Discrete Cosine Transformed Matrix 

m = size(I,1); n = size(I,2);   %Can also use [m n] = size(i)
i = zeros(m,n);   %Can also use I = zeros(size(i))

for x = 1:m
    for y = 1:n
        
        for p =1:m
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
                
                i(x,y) = i(x,y) + Ap*Aq*I(p,q)*cos((pi*(2*(x-1)+1)*(p-1))/(2*m))*cos((pi*(2*(y-1)+1)*(q-1))/(2*n)); 
            end
        end
        
    end
end


end
