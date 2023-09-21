function ImageCompressRasPi()

%fileID = fopen('RasPi_Flow.txt','w');
%clear myPi;

myPi = raspi;
cam = cameraboard(myPi,'Resolution','640x480');

ImageRGB = snapshot(cam);

%CompressedImage = ImageCompress(ImageRGB);

%imagesc(ImageRGB);
displayImage(myPi,ImageRGB);
%displayImage(myPi,CompressedImage);

%{
figure();
subplot(121);imshow(ImageRGB);
subplot(122);imshow(CompressedImage);
%}
%fclose(fileID);

end
