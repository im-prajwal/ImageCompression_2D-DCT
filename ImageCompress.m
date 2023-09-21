function RGB_reconstruct = ImageCompress(ImageRGB)

%Reading the Image and RGB to YCbCr colour space conversion:
ImageYCbCr = rgb2ycbcr(ImageRGB);


%YCbCr separated into Individual Channels(planes):
Y = ImageYCbCr(:,:,1);
Cb = ImageYCbCr(:,:,2);
Cr = ImageYCbCr(:,:,3);


%Chroma Sub-Sampling(Down-Sampling):
Cb_down = imresize(Cb, 0.5 , 'bilinear');
Cr_down = imresize(Cr, 0.5 , 'bilinear');


%Converting images to double data type:
Y = double(Y);
Cb_down = double(Cb_down);
Cr_down = double(Cr_down);


%Shifting the blocks to be centered around 0 rather than 128:
for i = 1:size(Y,1)
    for j = 1:size(Y,2)
        Y(i,j) = Y(i,j)-128;
    end
end
for i = 1:size(Cb_down,1)
    for j = 1:size(Cb_down,2)
        Cb_down(i,j) = Cb_down(i,j)-128;
    end
end
for i = 1:size(Cr_down,1)
    for j = 1:size(Cr_down,2)
        Cr_down(i,j) = Cr_down(i,j)-128;
    end
end


%Zero Padding the image to get integer number of 8x8 Blocks:
%For Luma(Y) Image:
if remainder(size(Y,1),8)~=0
    Y=[Y;zeros(8-remainder(size(Y,1),8),size(Y,2))];
end
if remainder(size(Y,2),8)~=0
    Y=[Y zeros(size(Y,1),8-remainder(size(Y,2),8))];
end

%For Cb_down Image:
if remainder(size(Cb_down,1),8)~=0
    Cb_down=[Cb_down;zeros(8-remainder(size(Cb_down,1),8),size(Cb_down,2))];
end
if remainder(size(Cb_down,2),8)~=0
    Cb_down=[Cb_down zeros(size(Cb_down,1),8-remainder(size(Cb_down,2),8))];
end

%For Cr_down Image:
if remainder(size(Cr_down,1),8)~=0
    Cr_down=[Cr_down;zeros(8-remainder(size(Cr_down,1),8),size(Cr_down,2))];
end
if remainder(size(Cr_down,2),8)~=0
    Cr_down=[Cr_down zeros(size(Cr_down,1),8-remainder(size(Cr_down,2),8))];
end


%Dividing Image into 8x8 Blocks and applying Block wise(8x8 Block) DCT:
dct = @myDCT2;        %Defining Anonymous Function Handle

Y_dct = blockProcess(Y,[8 8],dct);
Cb_down_dct = blockProcess(Cb_down,[8 8],dct);
Cr_down_dct = blockProcess(Cr_down,[8 8],dct);


%Initialization of Quantization matrices for Chrominance and Luminance:
%Quantization Table for Luminance:
Qy = [16 11 10 16 24 40 51 61 ; 12 12 14 19 26 58 60 55 ;
14 13 16 24 40 57 69 56 ; 14 17 22 29 51 87 80 62 ;
18 22 37 56 68 109 103 77 ; 24 35 55 64 81 104 113 92;
49 64 78 87 103 121 120 101 ; 72 92 95 98 112 100 103 99];

%Quantization Table for Chrominance:
Qc = [17 18 24 47 99 99 99 99 ; 18 21 26 66 99 99 99 99 ;
24 26 56 99 99 99 99 99 ; 47 66 99 99 99 99 99 99;
99 99 99 99 99 99 99 99 ; 99 99 99 99 99 99 99 99;
99 99 99 99 99 99 99 99 ; 99 99 99 99 99 99 99 99];

%Q_factor = input('Enter Quantization Factor such that 1<= Q-Factor <=100: ');
Q_factor = 50;

%Determining Quantization Scaling factor: 
if Q_factor<50
    Q_scale = floor(5000/Q_factor);
else
    Q_scale = 200 - 2*Q_factor;
end

Qy = round(Qy.*(Q_scale/100));
Qc = round(Qc.*(Q_scale/100));


%Quantization of Luma(Y) and Chroma(Cb,Cr) images:
Y_quant = @(Y_dct) round((Y_dct)./Qy);      %Defining Anonymous Function Handle
Cb_quant = @(Cb_down_dct) round((Cb_down_dct)./Qc);      %Defining Anonymous Function Handle
Cr_quant = @(Cr_down_dct) round((Cr_down_dct)./Qc);

Y_dct_quant = blockProcess(Y_dct,[8 8],Y_quant);
Cb_down_dct_quant = blockProcess(Cb_down_dct,[8 8],Cb_quant);
Cr_down_dct_quant = blockProcess(Cr_down_dct,[8 8],Cr_quant);


%Dequantization of Luma(Y) and Chroma(Cb,Cr) images:
Y_dequant = @(Y_dct_quant) round((Y_dct_quant).*Qy);      %Defining Anonymous Function Handle
Cb_dequant = @(Cb_down_dct_quant) round((Cb_down_dct_quant).*Qc);      %Defining Anonymous Function Handle
Cr_dequant = @(Cr_down_dct_quant) round((Cr_down_dct_quant).*Qc);

Y_dct_dequant = blockProcess(Y_dct_quant,[8 8],Y_dequant);
Cb_down_dct_dequant = blockProcess(Cb_down_dct_quant,[8 8],Cb_dequant);
Cr_down_dct_dequant = blockProcess(Cr_down_dct_quant,[8 8],Cr_dequant);


%Dividing Image into 8x8 Blocks and applying Block wise(8x8 Block) IDCT:
idct = @myIDCT2;        %Defining Anonymous Function Handle

Y_idct = blockProcess(Y_dct_dequant,[8 8],idct);
Cb_down_idct = blockProcess(Cb_down_dct_dequant,[8 8],idct);
Cr_down_idct = blockProcess(Cr_down_dct_dequant,[8 8],idct);


%Re-shifting the blocks to original center(127):
for i = 1:size(Y_idct,1)
    for j = 1:size(Y_idct,2)
        Y_idct(i,j) = Y_idct(i,j)+128;
    end
end
for i = 1:size(Cb_down_idct,1)
    for j = 1:size(Cb_down_idct,2)
        Cb_down_idct(i,j) = Cb_down_idct(i,j)+128;
    end
end
for i = 1:size(Cr_down_idct,1)
    for j = 1:size(Cr_down_idct,2)
        Cr_down_idct(i,j) = Cr_down_idct(i,j)+128;
    end
end


%Chroma Up-Sampling:
Cb_up = imresize(Cb_down_idct, 2, 'bilinear');
Cr_up = imresize(Cr_down_idct, 2, 'bilinear');


%Reconstructing Luma(Y) and Chroma(Cb,Cr) images to original size:
Y_reconstruct = Y_idct(1:size(Y,1), 1:size(Y,2));
Cb_up_reconstruct = Cb_up(1:size(Cb,1), 1:size(Cb,2));
Cr_up_reconstruct = Cr_up(1:size(Cr,1), 1:size(Cr,2));


%Reconstructing back to image similar to original YCbCr image:
YCbCr_reconstruct = zeros([size(Y,1),size(Y,2),3]);

YCbCr_reconstruct(:,:,1) = Y_reconstruct;
YCbCr_reconstruct(:,:,2) = Cb_up_reconstruct;
YCbCr_reconstruct(:,:,3) = Cr_up_reconstruct;

YCbCr_reconstruct = uint8(YCbCr_reconstruct);


% Reconstructing back to image similar to original RGB image:
RGB_reconstruct = uint8(ycbcr2rgb(YCbCr_reconstruct));


end