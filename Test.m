clear; close all; clc;

%Reading the Image and RGB to YCbCr colour space conversion:
ImageRGB = imread('LenaColor_512.tif');
ImageYCbCr = rgb2ycbcr(ImageRGB);

figure('Name','RGB and YCbCr Images');
subplot(121); imshow(ImageRGB); title('RGB Image');
subplot(122); imshow(ImageYCbCr); title('YCbCr Image');


%YCbCr separated into Individual Channels(planes):
Y = ImageYCbCr(:,:,1);
Cb = ImageYCbCr(:,:,2);
Cr = ImageYCbCr(:,:,3);

figure('Name','YCbCr Image Channels');
subplot(131); imshow(Y); title('Luma(Y)');
subplot(132); imshow(Cb); title('Chroma Blue(Cb)');
subplot(133); imshow(Cr); title('Chroma Red(Cr)');


%Chroma Sub-Sampling(Down-Sampling):
Cb_down = imresize(Cb, 0.5 , 'bilinear');
Cr_down = imresize(Cr, 0.5 , 'bilinear');

figure('Name','Down-Sampled CbCr Images');
subplot(121); imshow(Cb_down); title('Down-Sampled Cb');
subplot(122); imshow(Cr_down); title('Down-Sampled Cr');


%Converting images to double data type:
Y = double(Y);
Cb_down = double(Cb_down);
Cr_down = double(Cr_down);

figure('Name','Double Data-Type CbCr Images');
subplot(131); imshow(Y); title('Double Y');
subplot(132); imshow(Cb_down); title('Double Cb');
subplot(133); imshow(Cr_down); title('Double Cr');


%Shifting the blocks to be centered around 0 rather than 128:
for i = 1:height(Y)
    for j = 1:width(Y)
        Y(i,j) = Y(i,j)-128;
    end
end
for i = 1:height(Cb_down)
    for j = 1:width(Cb_down)
        Cb_down(i,j) = Cb_down(i,j)-128;
    end
end
for i = 1:height(Cr_down)
    for j = 1:width(Cr_down)
        Cr_down(i,j) = Cr_down(i,j)-128;
    end
end


%{
%Zero Padding the image to get integer number of 8x8 Blocks:
%For Luma(Y) Image
if rem(size(Y,1),8)~=0                      
    Y = [Y, zeros(8-rem(size(Y,1),8))];
end
if rem(size(Y,2),8)~=0
    Y = [Y, zeros(8-rem(size(Y,2),8))];
end

%For Cb_down Image
if rem(size(Cb_down,1),8)~=0                
    Cb_down = [Cb_down, zeros(8-rem(size(Cb_down,1),8))];
end
if rem(size(Cb_down,2),8)~=0
    Cb_down = [Cb_down, zeros(8-rem(size(Cb_down,2),8))];
end

%For Cr_down Image
if rem(size(Cr_down,1),8)~=0                
    Cr_down = [Cr_down, zeros(8-rem(size(Cr_down,1),8))];
end
if rem(size(Cr_down,2),8)~=0
    Cr_down = [Cr_down, zeros(8-rem(size(Cr_down,2),8))];
end
%}


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

figure('Name','Zero Padded Down-Sampled Images');
subplot(131); imshow(Y); title('Luma(Y)');
subplot(132); imshow(Cb_down); title('Chroma Blue(Cb)');
subplot(133); imshow(Cr_down); title('Chroma Red(Cr)');


%Dividing Image into 8x8 Blocks and applying Block wise(8x8 Block) DCT:
dct = @myDCT2;        %Defining Anonymous Function Handle

Y_dct = blockProcess(Y,[8 8],dct);
Cb_down_dct = blockProcess(Cb_down,[8 8],dct);
Cr_down_dct = blockProcess(Cr_down,[8 8],dct);

figure('Name','Transformed Images');
subplot(131); imshow(Y_dct); title('DCT Luma(Y)');
subplot(132); imshow(Cb_down_dct); title('DCT Cb');
subplot(133); imshow(Cr_down_dct); title('DCT Cr');


%Initialization of Quantization matrices for Chrominance and Luminance:
%Quantization Table for Luminance:
Qy = [16 11 10 16 24 40 51 61 ; 12 12 14 19 26 58 60 55 ;
      14 13 16 24 40 57 69 56 ; 14 17 22 29 51 87 80 62 ;
      18 22 37 56 68 109 103 77 ; 24 35 55 64 81 104 113 92 ;
      49 64 78 87 103 121 120 101 ; 72 92 95 98 112 100 103 99 ];

%Quantization Table for Chrominance:
Qc = [17 18 24 47 99 99 99 99 ; 18 21 26 66 99 99 99 99 ;
      24 26 56 99 99 99 99 99 ; 47 66 99 99 99 99 99 99 ;
      99 99 99 99 99 99 99 99 ; 99 99 99 99 99 99 99 99 ;
      99 99 99 99 99 99 99 99 ; 99 99 99 99 99 99 99 99 ];

Q_factor = input('Enter Quantization Factor such that 1<= Q-Factor <=100: ');

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

Y_dct_quant = blockProcess(Y_dct,[8 8], Y_quant);
Cb_down_dct_quant = blockProcess(Cb_down_dct,[8 8], Cb_quant);
Cr_down_dct_quant = blockProcess(Cr_down_dct,[8 8], Cr_quant);

figure('Name','Quantized Images');
subplot(131); imshow(Y_dct_quant); title('DCT Luma Quantized');
subplot(132); imshow(Cb_down_dct_quant); title('DCT Cb Quantized');
subplot(133); imshow(Cr_down_dct_quant); title('DCT Cr Quantized');




%Zig-Zag Sequencing:
Y_zigzag = zigzag(Y_dct_quant);
Cb_zigzag = zigzag(Cb_down_dct_quant);
Cr_zigzag = zigzag(Cr_down_dct_quant);


%Run Length Encoding(RLE):
Y_rle = rle(Y_zigzag);
Cb_rle = rle(Cb_zigzag);
Cr_rle = rle(Cr_zigzag);


% Huffman encoding
% LUMA
symbol_y=y_rle
U_y=unique(symbol_y);
F_y=histc(symbol_y,U_y);
prob_y=F_y/length(symbol_y);

% Get the dictionary of the given alphabet.
dict_y=huffmandict(U_y,prob_y)
% Get the encoded signal.
encoded_y=huffmanenco(symbol_y, dict_y)

%cb
symbol_cb=cb_rle
U_cb=unique(symbol_cb);
F_cb=histc(symbol_cb,U_cb);
prob_cb=F_cb/length(symbol_cb);

% Get the dictionary of the given alphabet.
dict_cb=huffmandict(U_cb,prob_cb)
% Get the encoded signal.
encoded_cb=huffmanenco(symbol_cb, dict_cb)

%cr
symbol_cr=cr_rle
U_cr=unique(symbol_cr);
F_cr=histc(symbol_cr,U_cr);
prob_cr=F_cr/length(symbol_cr);

% Get the dictionary of the given alphabet.
dict_cr=huffmandict(U_cr,prob_cr)
% Get the encoded signal.
encoded_cr=huffmanenco(symbol_cr, dict_cr)




%%%%%%%%%%%%%%%%%%%%%%%%%% Decompression %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the decoded signal.
decoded_y=huffmandeco(encoded_y,dict_y)
decoded_cb=huffmandeco(encoded_cb,dict_cb)
decoded_cr=huffmandeco(encoded_cr,dict_cr)


%Run Length Dencoding(RLD):
Y_rld = rld(decoded_y);
Cb_rld = rld(decoded_cb);
Cr_rld = rld(decoded_cr);


%Inverse Zig-Zag Sequencing:
Y_izigzag = izigzag(Y_rld, size(Y,1), size(Y,2));
Cb_izigzag = izigzag(Cb_rld, size(Cb,1), size(Cb,2));
Cr_izigzag = izigzag(Cr_rld, size(Cr,1), size(Cr,2));
 



%Dequantization of Luma(Y) and Chroma(Cb,Cr) images:
Y_dequant = @(Y_izigzag) round((Y_izigzag).*Qy);      %Defining Anonymous Function Handle
Cb_dequant = @(Cb_izigzag) round((Cb_izigzag).*Qc);      %Defining Anonymous Function Handle
Cr_dequant = @(Cr_izigzag) round((Cr_izigzag).*Qc);

Y_dct_dequant = blockProcess(Y_dct_quant,[8 8], Y_dequant);
Cb_down_dct_dequant = blockProcess(Cb_down_dct_quant,[8 8], Cb_dequant);
Cr_down_dct_dequant = blockProcess(Cr_down_dct_quant,[8 8], Cr_dequant);

figure('Name','Dequantized Images');
subplot(131); imshow(Y_dct_dequant); title('DCT Y Dequantized');
subplot(132); imshow(Cb_down_dct_dequant); title('DCT Cb Dequantized');
subplot(133); imshow(Cr_down_dct_dequant); title('DCT Cr Dequantized');


%Dividing Image into 8x8 Blocks and applying Block wise(8x8 Block) IDCT:
idct = @myIDCT2;        %Defining Anonymous Function Handle

Y_idct = blockProcess(Y_dct_dequant,[8 8], idct);
Cb_down_idct = blockProcess(Cb_down_dct_dequant,[8 8], idct);
Cr_down_idct = blockProcess(Cr_down_dct_dequant,[8 8], idct);

figure('Name','Inverse Transformed Images');
subplot(131); imshow(Y_idct); title('IDCT Y');
subplot(132); imshow(Cb_down_idct); title('IDCT Cb');
subplot(133); imshow(Cr_down_idct); title('IDCT Cr');


%Re-shifting the blocks to original center(127):
for i = 1:height(Y_idct)
    for j = 1:width(Y_idct)
        Y_idct(i,j) = Y_idct(i,j)+128;
    end
end
for i = 1:height(Cb_down_idct)
    for j = 1:width(Cb_down_idct)
        Cb_down_idct(i,j) = Cb_down_idct(i,j)+128;
    end
end
for i = 1:height(Cr_down_idct)
    for j = 1:width(Cr_down_idct)
        Cr_down_idct(i,j) = Cr_down_idct(i,j)+128;
    end
end


%Chroma Up-Sampling:
Cb_up = imresize(Cb_down_idct, 2, 'bilinear');
Cr_up = imresize(Cr_down_idct, 2, 'bilinear');

figure('Name','Up-Sampled CbCr Images');
subplot(121); imshow(Cb_up); title('Up-Sampled Cb');
subplot(122); imshow(Cr_up); title('Up-Sampled Cr');


%Reconstructing Luma(Y) and Chroma(Cb,Cr) images to original size:
Y_reconstruct = Y_idct(1:height(Y), 1:width(Y));
Cb_up_reconstruct = Cb_up(1:height(Cb), 1:width(Cb));
Cr_up_reconstruct = Cr_up(1:height(Cr), 1:width(Cr));


%Reconstructing back to image similar to original YCbCr image:
YCbCr_reconstruct = zeros([height(Y),width(Y),3]);

YCbCr_reconstruct(:,:,1) = Y_reconstruct;
YCbCr_reconstruct(:,:,2) = Cb_up_reconstruct;
YCbCr_reconstruct(:,:,3) = Cr_up_reconstruct;

YCbCr_reconstruct = uint8(YCbCr_reconstruct);


% Reconstructing back to image similar to original RGB image:
RGB_reconstruct = uint8(ycbcr2rgb(YCbCr_reconstruct));

figure('Name','Compressed Images'); 
subplot(121); imshow(YCbCr_reconstruct); title('Compressed YCbCr Image');
subplot(122); imshow(RGB_reconstruct); title('Compressed RGB Image');


% Mapping Matrix to Image and Saving Compressed Image to desired location:
imwrite(RGB_reconstruct,'E:\Engineering\MATLAB & Simulink\MATLAB\Image Compression\Images\BP Compressed LenaColor_512.jpg');

