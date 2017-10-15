% Final Project
% Implement Panoramic Image Stitching using Invarient Features 
% (Matthew Brown & David G. Lowe 2007)
% Shih-Hsuan CHu
% N10854189

%===============================================================
clear all;

% Image5 + Image4 
Matche4=match('IMG5.jpg','IMG4.jpg');
[H54, inlier54]=RANSAC(Matche4);
Im5=imread('IMG5.jpg');
Im4=imread('IMG4.jpg');
Im5tr=imtransform(Im5,maketform('affine',H54'));
imwrite(Im5tr,'IMG5tr.jpg')
[x5 y5 z]=size(Im5tr);
[x4 y4 z]=size(Im4);
mask54=zeros(2*x4,y4+y5);

% keep track of the position of the first pixel    
map4=[x4/2,0];  
map5=[x4/2,y4];

mid5=[size(Im5,1)/2,size(Im5,2)/2,1]*H54;
mid5=mid5(1,1:2);
mid4=[x4/2+map4(1),y4/2+map4(2)];
mid5=[mid5(1)+map5(1),mid5(2)+map5(2)];

inlier54_=[inlier54(:,1)+map5(1),inlier54(:,2)+map5(2),inlier54(:,3)+map4(1),inlier54(:,4)+map4(2)];

dx=round((sum(inlier54_(:,3))-sum(inlier54_(:,1)))/length(inlier54_));
dy=round((sum(inlier54_(:,4))-sum(inlier54_(:,2)))/length(inlier54_));
map5=[map5(1)+dx,map5(2)+dy];
mid4=[mid5(1)+dx,mid5(2)+dy];

mask4=zeros(x4,y4);
for i=1:x4
    for j=1:y4
        if(Im4(i,j,1)>0 |Im4(i,j,2)>0 |Im4(i,j,3)>0 )
        mask4(i,j)=1;
        end
    end
end

mask5=zeros(x5,y5);
for i=1:x5
    for j=1:y5
        if(Im5tr(i,j,1)>0 |Im5tr(i,j,2)>0 |Im5tr(i,j,3)>0 )
        mask5(i,j)=2;
        end
    end
end

mask54(1+map4(1):map4(1)+x4,1+map4(2):map4(2)+y4)=mask4;
mask54(1+map5(1):map5(1)+x5,1+map5(2):map5(2)+y5)=mask54(1+map5(1):map5(1)+x5,1+map5(2):map5(2)+y5)+mask5;

clear temp
temp(:,:,1)=zeros(map4(1),y4);
temp(:,:,2)=zeros(map4(1),y4);
temp(:,:,3)=zeros(map4(1),y4);
Im4_=[temp;Im4;temp];

temp2=zeros(size(Im5tr));
Image54=appendimages(Im4_,temp2);
img1=Image54;
img2=Image54-img1;
Image54(1+map5(1):map5(1)+x5,1+map5(2):map5(2)+y5,:)=Image54(1+map5(1):map5(1)+x5,1+map5(2):map5(2)+y5,:)+Im5tr;
img2(1+map5(1):map5(1)+x5,1+map5(2):map5(2)+y5,:)=img2(1+map5(1):map5(1)+x5,1+map5(2):map5(2)+y5,:)+Im5tr;

[x y]=size(mask54);
for i=1:x
    for j=1:y
        if(mask54(i,j)==3)
            Image54(i,j,:)=Im4_(i,j,:);
        end
    end
end

imwrite(Image54,'Image54.jpg');


%===============================================================
%Image3+Image45

Matche3=match('Image54.jpg','IMG3.jpg');
[H43, inlier43]=RANSAC(Matche3);
Im3=imread('IMG3.jpg');
Im4tr2=imtransform(Image54,maketform('affine',H43'));
imwrite(Im4tr2,'IMG45tr.jpg')

[x45 y45 z]=size(Im4tr2);
[x3 y3 z]=size(Im3);
mask43=zeros(x3+x45,y3+y45);

map3=[x3,0];
mid3=[x3/2+map3(1),y3/2+map3(1)];

map4_=[map4(1),map4(2),1]*H43;
map4_=round(map4_(1,1:2));
mid4_=[mid4_,1]*H43;
mid4_=round(mid4_(1,1:2));

inlier43_=[inlier43(:,1)+map4_(1),inlier43(:,2)+map4_(2),inlier43(:,3)+map3(1),inlier43(:,4)+map3(2)];

dx=round((sum(inlier43_(:,3))-sum(inlier43_(:,1)))/length(inlier43_));
dy=round((sum(inlier43_(:,4))-sum(inlier43_(:,2)))/length(inlier43_));

map4_=[map4_(1)+dx,map4_(2)+dy];
mid4_=[mid4_(1)+dx,mid4_(2)+dy];

mask3=zeros(x3,y3);
for i=1:x3
    for j=1:y3
        if(Im3(i,j,1)>0 |Im3(i,j,2)>0 |Im3(i,j,3)>0 )
        mask3(i,j)=1;
        end
    end
end

mask45=zeros(x45,y45);
for i=1:x45
    for j=1:y45
        if(Im4tr2(i,j,1)>0 |Im4tr2(i,j,2)>0 |Im4tr2(i,j,3)>0 )
        mask45(i,j)=2;
        end
    end
end

mask43(1+map3(1):map3(1)+x3,1+map3(2):map3(2)+y3)=mask3;
mask43(1+map4_(1):map4_(1)+x45,1+map4_(2):map4_(2)+y45)=mask43(1+map4_(1):map4_(1)+x45,1+map4_(2):map4_(2)+y45)+mask45;

clear temp img1 img2
temp=zeros(size(Im3));

Im3_=[temp;Im3;temp];

temp2=zeros(size(Im4tr2));
Image34=appendimages(Im3_,temp2);
img1=Image34;
img2=Image34-img1;

Image34(1+map4_(1):map4_(1)+x45,1+map4_(2):map4_(2)+y45,:)=Image34(1+map4_(1):map4_(1)+x45,1+map4_(2):map4_(2)+y45,:)+Im4tr2;
img2(1+map4_(1):map4_(1)+x45,1+map4_(2):map4_(2)+y45,:)=Im4tr2;


[x y]=size(mask43);
for i=1:x
    for j=1:y
        if(mask43(i,j)==3)
            Image34(i,j,:)=img1(i,j,:);
        end
    end
end  

imwrite(Image34,'Image34.jpg');


% cut the edge
min_x=size(mask43,1);
max_x=0;
for i=1:size(mask43,1)
    if(sum(mask43(i,:))>0)
        if(i<min_x)
            min_x=i;
        end
        if(i>max_x)
            max_x=i;
        end
    end
end

max_y=0;
for i=1:size(mask43,2)
    if(sum(mask43(:,i))>0)
        if(i>max_y)
            max_y=i;
        end
    end
end

Image34_=Image34(min_x:max_x,1:max_y,:);
imwrite(Image34_,'Image34_.jpg');
map3(1)=map3(1)-min_x+1;
mid3(1)=mid3(1)-min_x+1;

%===============================================================
%Image2+Image34_

Matche2=match('Image34_.jpg','IMG2.jpg');
[H32, inlier32]=RANSAC(Matche2);
Im2=imread('IMG2.jpg');
Im3tr=imtransform(Image34_,maketform('affine',H32'));
imwrite(Im3tr,'IMG23tr2.jpg');
[x34 y34 z]=size(Im3tr);
[x2 y2 z]=size(Im2);

mask23=zeros(x2+x34,y2+y34);

map2=[x2/2,0];
mid2=[x2/2+map2(1),y2/2+map2(1)];

map3_=[map3(1)+1,map3(2)+1,1]*H32;  
map3_=round(map3_(1,1:2));  
mid3_=[mid3(1)+1,mid3(2)+1,1]*H32;
mid3_=round(mid3_(1,1:2));

inlier32_=[inlier32(:,1)+map3_(1),inlier32(:,2)+map3_(2),inlier32(:,3)+map2(1),inlier32(:,4)+map2(2)];

dx=round((sum(inlier32_(:,3))-sum(inlier32_(:,1)))/length(inlier32_));
dy=round((sum(inlier32_(:,4))-sum(inlier32_(:,2)))/length(inlier32_));

map3_=[map3_(1)+dx,map3_(2)+dy];
mid3_=[mid3_(1)+dx,mid3_(2)+dy];

mask2=zeros(x2,y2);
for i=1:x2
    for j=1:y2
        if(Im2(i,j,1)>0 |Im2(i,j,2)>0 |Im2(i,j,3)>0 )
        mask2(i,j)=1;
        end
    end
end

mask34=zeros(x34,y34);
for i=1:x34
    for j=1:y34
        if(Im3tr(i,j,1)>0 |Im3tr(i,j,2)>0 |Im3tr(i,j,3)>0 )
        mask34(i,j)=2;
        end
    end
end

mask23(1+map2(1):map2(1)+x2,1+map2(2):map2(2)+y2)=mask2;
mask23(1+map3_(1):map3_(1)+x34,1+map3_(2):map3_(2)+y34)=mask23(1+map3_(1):map3_(1)+x34,1+map3_(2):map3_(2)+y34)+mask34;

clear temp
temp=zeros(size(Im2(1:map2(1),:,:)));

Im2_=[temp;Im2;temp];

temp2=zeros(size(Im3tr));
Image23=appendimages(Im2_,temp2);
img1=Image23;
img2=Image23-img1;

Image23(1+map3_(1):map3_(1)+x34,1+map3_(2):map3_(2)+y34,:)=Image23(1+map3_(1):map3_(1)+x34,1+map3_(2):map3_(2)+y34,:)+Im3tr;
img2(1+map3_(1):map3_(1)+x34,1+map3_(2):map3_(2)+y34,:)=img2(1+map3_(1):map3_(1)+x34,1+map3_(2):map3_(2)+y34,:)+Im3tr;
[x y]=size(mask23);

for i=1:x
    for j=1:y
        if(mask23(i,j)==3)
            Image23(i,j,:)=img1(i,j,:);
        end
    end
end  

imwrite(Image23,'Image23.jpg');


% cut the edge
min_x=size(mask23,1);
max_x=0;
for i=1:size(mask23,1)
    if(sum(mask23(i,:))>0)
        if(i<min_x)
            min_x=i;
        end
        if(i>max_x)
            max_x=i;
        end
    end
end

max_y=0;
for i=1:size(mask23,2)
    if(sum(mask23(:,i))>0)
        if(i>max_y)
            max_y=i;
        end
    end
end

Image23_=Image23(min_x:max_x,1:max_y,:);
imwrite(Image23_,'Output.jpg');



%%=========================




