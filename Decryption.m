function DecImg=Decryption(EncImg,H1)
    %% construct the key
    N=size(EncImg,1);
    n=size(H1,2)/2;
    HexBin=Hex2Bin(H1,4);
    HexBin=HexBin(:)';
        
    KeyDec=zeros(1,n);
    for i=1:1:n
        KeyDec(i)=bin2dec(HexBin((i-1)*8+1:i*8));
    end
    
     x0=bitxor(KeyDec(1),KeyDec(2));
    for i=3:16
        x0=bitxor(x0,KeyDec(i));
    end
    
    r=bitxor(KeyDec(17),KeyDec(18));
    for i=19:32
        r=bitxor(r,KeyDec(i));
    end
    
    r=3.98+(r/(256*100));
    x0=x0/256;
    
    x=zeros(N*N,1);
    x(1)=x0;
    for i=2:N*N
        x(i)=r*x(i-1)*(1-x(i-1));
    end
    
    %% Rev difussion
    K=floor(0+255*x);
    EncImg=EncImg(:);
    RevPerImg=bitxor(EncImg,K);    
    %% Rev permutation
    [~, Ix]=sort(x);    
    DecImg(Ix)=RevPerImg;
    %% convert vector to matrix
    DecImg=reshape(DecImg,[N,N]);

end