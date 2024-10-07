clear
clc
close all
format compact
%% Input Data
KeyHex = '6b679b3c77826d30a79e612114a8c18df984c176f4e529f684748ad052241b17'; %% s a 128 digital hex key
PlainImg=imread('Cameraman1024.bmp');      %Image size 256*256
N=size(PlainImg,1);
H1=HashFunction(PlainImg,'SHA-256');
PlainImg=double(PlainImg);
%% Encryption & Decryption
EncImg=Encryption(PlainImg,KeyHex,H1);
DecImg=Decryption(EncImg,KeyHex,H1);

%% Input Data
k=1
S=N*N*8;

for i=1:64
    for j=1:4
        KeyBin=Hex2Bin(KeyHex,4);
        if KeyBin(i,j)=='0'
            KeyBin(i,j)='1';
        else
            KeyBin(i,j)='0';
        end
        KeyDec=bin2dec(KeyBin);
        NewKeyHex=dec2hex(KeyDec);
        KeyHex2=NewKeyHex';
       
        % Encryption & Decryption      
        EncImg2=Encryption(PlainImg,KeyHex2,H1);
        DecImg2=Decryption(EncImg,KeyHex2,H1);

        B1=dec2bin(EncImg);
        B2=dec2bin(EncImg2);
        dist = sum(sum(B1 ~= B2));
        NBCR1(k)=dist/S*100;

        B1=dec2bin(DecImg);
        B2=dec2bin(DecImg2);
        dist = sum(sum(B1 ~= B2));
        NBCR2(k)=dist/S*100;
    
        k=k+1
        
   end
end