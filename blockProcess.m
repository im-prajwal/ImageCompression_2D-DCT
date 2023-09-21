function matOut = blockProcess(matIn,blockSize,funProcess)
%Extracts specified size blocks from an matrix or an image. 
%Performs the specified function/process on the specified size block.
%Input Arguments: Input Matrix/Image,Row size,Column Size,Function Handle
%Output: Block Processed Matrix/Image

M = size(matIn,1); N = size(matIn,2);
m = blockSize(1,1); n = blockSize(1,2);
matOut = zeros(M,N);

for I = 0:(M/m)-1
    for J = 0:(N/n)-1
        
        matTempIn = matIn(I*m+1:(I+1)*m-1+1 , J*n+1:(J+1)*n-1+1);
        matTempOut = zeros(m,n);
        
        for i = I*m:(I+1)*m-1
            for j = J*n:(J+1)*n-1
                matTempOut = funProcess(matTempIn);
            end
        end
        
        matOut(I*m+1:(I+1)*m-1+1 , J*n+1:(J+1)*n-1+1) = matTempOut;  
        
    end
end


end