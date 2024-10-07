clc
clear
close all
format compact

PlainImg=imread('Lena512.bmp');
PlainImg=double(PlainImg);
N=size(PlainImg,1);
H1=HashFunction(PlainImg,'SHA-256');
%%  Encryption and Decryption
Runsize=10;
for i=1:Runsize
    tic
        [EncImg]=Encryption(PlainImg,H1);
    tEnc(i)=toc;
    tic
        DecImg=Decryption(EncImg,H1);
    tDec(i)=toc;
end
fprintf('\n%d Runs --> Average Encryption Time = %f',Runsize,sum(tEnc)/Runsize);
fprintf('\n%d Runs --> Average Decryption Time = %f',Runsize,sum(tDec)/Runsize);


%%
figure('Name','Simulation Result ...')
subplot(2,3,1),imshow(uint8(PlainImg)),  title('Plain Image');
subplot(2,3,2),imshow(uint8(EncImg)),    title('Cipher Image');
subplot(2,3,3),imshow(uint8(DecImg)),    title('Decrypted Image');
subplot(2,3,4),imhist(uint8(PlainImg)),  title('Histogram of Plain Image');
subplot(2,3,5),imhist(uint8(EncImg)),    title('Histogram of Cipher Image');
subplot(2,3,6),imhist(uint8(DecImg)),    title('Histogram of Decrypted Image');
% Test Parameter
DifPlainDec=sum(uint8(PlainImg(:))-uint8(DecImg(:)));
fprintf('\n\nPlainImage - DecryptedImage = %d',DifPlainDec);
% 
PlainImg_Entropy = Entropy(PlainImg,N);
fprintf('\n\nPlainImage  Entropy = %f',PlainImg_Entropy);
EncImg_Entropy = Entropy(EncImg,N);
fprintf('\nCipherImage Entropy = %f',EncImg_Entropy);

fprintf('\n\nCorrelation Coefficient:\n');
CC=AdjancyCorrPixelRandNew(PlainImg,EncImg);
disp(CC);

%% NPCR and UACI Test
%Encryption and Decryption for 1 bit change in Plain Image
fprintf('\nNPCR and UACI Test ...')

PlainImg1bit=PlainImg;      
pos1=1+floor(rand(1)*N);
pos2=1+floor(rand(1)*N);

fprintf('\nBefore change 1 bit of PlainImage at location (%d,%d) = %d',pos1,pos2,PlainImg1bit(pos1,pos2));
PlainImg1bit(pos1,pos2) =uint8(mod(double(PlainImg1bit(pos1,pos2)+1),256));
fprintf('\nAfter change 1 bit of PlainImage at location (%d,%d) = %d',pos1,pos2,PlainImg1bit(pos1,pos2));
H1bit=HashFunction(PlainImg1bit,'SHA-256');
[EncImg1bit]=Encryption(PlainImg1bit,H1bit);
[DecImg1bit] = Decryption(EncImg1bit,H1bit);

[npcr1, uaci1]= NPCR_UACI(uint8(EncImg),uint8(EncImg1bit));
fprintf('\nNPCR = %f   UACI=%f \n',npcr1, uaci1);
%%  Cropping attack
fprintf('\nCropping attack ... \n')
figure('Name','Cropping attack ...'),
if N==256
    crop32=32;
    crop16=64;
    crop4=128;
    crop2=256;
elseif N==512
    crop32=64;
    crop16=128;
    crop4=256;
    crop2=512;
elseif N==1024
    crop32=128;
    crop16=256;
    crop4=512;
    crop2=1024;
end
%*****************************************************************************
EncImgCrop32=EncImg;
EncImgCrop32(1:crop32, 1:crop32)=0;
DecImgCrop32 = Decryption(EncImgCrop32,H1);
PSNRCrop32=psnr(uint8(DecImgCrop32),uint8(PlainImg));
fprintf('PSNR of 1/16 cropped cipher image = %f \n',PSNRCrop32);
subplot(2,4,1), imshow(uint8(EncImgCrop32)),  title('1/32 Cropped Cipher Image ');
subplot(2,4,5), imshow(uint8(DecImgCrop32)),  title('Decrypted Image ');
%*****************************************************************************
EncImgCrop16=EncImg;
EncImgCrop16(1:crop16, 1:crop16)=0;
DecImgCrop16 = Decryption(EncImgCrop16,H1);
PSNRCrop16=psnr(uint8(DecImgCrop16),uint8(PlainImg));
fprintf('PSNR of 1/16 cropped cipher image = %f \n',PSNRCrop16);
subplot(2,4,2), imshow(uint8(EncImgCrop16)),  title('1/16 Cropped Cipher Image ');
subplot(2,4,6), imshow(uint8(DecImgCrop16)),  title('Decrypted Image ');
%*****************************************************************************************
EncImgCrop4=EncImg;
EncImgCrop4(1:crop4, 1:crop4)=0;
DecImgCrop4 = Decryption(EncImgCrop4,H1);
PSNRCrop4=psnr(uint8(DecImgCrop4),uint8(PlainImg));
fprintf('PSNR of 1/4  cropped cipher image = %f \n',PSNRCrop4);
subplot(2,4,3), imshow(uint8(EncImgCrop4)),  title('1/4 Cropped Cipher Image ');
subplot(2,4,7), imshow(uint8(DecImgCrop4)),  title('Decrypted Image ');
%*****************************************************************************************
EncImgCrop2=EncImg;
EncImgCrop2(1:crop4, 1:crop2)=0;
DecImgCrop2 = Decryption(EncImgCrop2,H1);
PSNRCrop2=psnr(uint8(DecImgCrop2),uint8(PlainImg));
fprintf('PSNR of 1/2  cropped cipher image = %f \n',PSNRCrop2);
subplot(2,4,4), imshow(uint8(EncImgCrop2)),  title('1/2 Cropped Cipher Image ');
subplot(2,4,8), imshow(uint8(DecImgCrop2)),  title('Decrypted Image ');


%% Salt and pepper noise attack
fprintf('\nSalt and pepper noise attack ... \n')
figure('Name','Salt and pepper noise attack ...'),
NoiseLevel=0.0005;
EncImgNoise0005=double(imnoise(uint8(EncImg),'salt & pepper',NoiseLevel));
DecImgNoise0005 = Decryption((EncImgNoise0005),H1);
PSNRnosie0005=psnr(uint8(DecImgNoise0005),uint8(PlainImg));
fprintf('Noise Level = %f, PSNR of nosiy cipher image = %f \n',NoiseLevel,PSNRnosie0005);
subplot(2,4,1), imshow(uint8(EncImgNoise0005)),  title('0.0005 Noisy Cipher Image ');
subplot(2,4,5), imshow(uint8(DecImgNoise0005)),  title('0.0005 Noisy Decrypted Image ');
%***********************************************************************************
NoiseLevel=0.005;
EncImgNoise005=double(imnoise(uint8(EncImg),'salt & pepper',NoiseLevel));
DecImgNoise005 = Decryption((EncImgNoise005),H1);
PSNRnosie005=psnr(uint8(DecImgNoise005),uint8(PlainImg));
fprintf('Noise Level = %f, PSNR of nosiy cipher image = %f \n',NoiseLevel,PSNRnosie005);
subplot(2,4,2), imshow(uint8(EncImgNoise005)),  title('0.005 Noisy Cipher Image ');
subplot(2,4,6), imshow(uint8(DecImgNoise005)),  title('0.005 Noisy Decrypted Image ');
%***********************************************************************************
NoiseLevel=0.05;
EncImgNoise05=double(imnoise(uint8(EncImg),'salt & pepper',NoiseLevel));
DecImgNoise05 = Decryption((EncImgNoise05),H1);
PSNRnosie05=psnr(uint8(DecImgNoise05),uint8(PlainImg));
fprintf('Noise Level = %f, PSNR of nosiy cipher image = %f \n',NoiseLevel,PSNRnosie05);
subplot(2,4,3), imshow(uint8(EncImgNoise05)),  title('0.05 Noisy Cipher Image ');
subplot(2,4,7), imshow(uint8(DecImgNoise05)),  title('0.05 Noisy Decrypted Image ');
%***********************************************************************************
NoiseLevel=0.1;
EncImgNoise1=double(imnoise(uint8(EncImg),'salt & pepper',NoiseLevel));
DecImgNoise1 = Decryption((EncImgNoise1),H1);
PSNRnosie1=psnr(uint8(DecImgNoise1),uint8(PlainImg));
fprintf('Noise Level = %f, PSNR of nosiy cipher image = %f \n',NoiseLevel,PSNRnosie1);
subplot(2,4,4), imshow(uint8(EncImgNoise1)),  title('0.1 Noisy Cipher Image ');
subplot(2,4,8), imshow(uint8(DecImgNoise1)),  title('0.1 Noisy Decrypted Image ');
