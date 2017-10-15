%======================================X
% find the range of inlier
yr=y2;
xd=map2(1)+x2;
p=mask23(:,yr);
xu=min(find(p==3));
p=mask23(xd,:);
yl=min(find(p==3));

dy_dx=(yr-yl+1)/(xd-xu+1)^2;
next=yr;
count=1;
for i=xu:xd
    next=yl+sqrt((xd-i+1)/0.0048);
    for j=yl:yr
        if (j<=next)
            Image23(i,j,:)=img1(i,j,:);
        elseif(j>next)
            Image23(i,j,:)=img2(i,j,:);
        end
    end
end 



clear temp
temp=ones(xd-xu+1,yr-yl+1);
temp1=fliplr(triu(temp,1))+fliplr((1/2)*eye(size(temp)));
temp1=fliplr(temp1);
temp2=temp-temp1;

A=Image23(xu:xd,yl:yr,:);
I1=double(img1(xu:xd,yl:yr,:));
I2=double(img2(xu:xd,yl:yr,:));
A(:,:,1)=I1(:,:,1).*temp1+I2(:,:,1).*temp2;
A(:,:,2)=I1(:,:,2).*temp1+I2(:,:,2).*temp2;
A(:,:,3)=I1(:,:,3).*temp1+I2(:,:,3).*temp2;
    
Image23(xu:xd,yl:yr,:)=A;

%===================================X
row=map4(1);
yu=min(find(mask54(row+1,:)==3));
yd=max(find(mask54(:,y4)==3));
clear list;
list=[];
for i=row+2:yd
    list=[list; i,y4];
end
Image54=blending(list, Image54,img1,img2,'V');
clear list;
list=[];
for i=yu:y4
   list=[list;row+1,i];
end
Image54=blending(list, Image54,img1,img2,'H');


%===============================================================

Matche3=match('IMG4.jpg','IMG3.jpg');
[H43, inlier43]=RANSAC(Matche3);
Im3=imread('IMG3.jpg');
Im4=imread('IMG4.jpg');
Im4tr=imtransform(Im4,maketform('affine',H43'));
imwrite(Im4tr,'IMG4tr.jpg')
[x4 y4 z]=size(Im4tr);
[x3 y3 z]=size(Im3);
mask43=zeros(x3+x4,y3+y4);

mid4=[size(Im4,1)/2,size(Im4,2)/2,1]*H43;
mid4=mid4(1,1:2);
map3=[x3/2,0];
map4=[x3/2,y3];
mid3=[x3/2+map3(1),y3/2+map3(2)];
mid4=[mid4(1)+map4(1),mid4(2)+map4(2)];


inlier43=[inlier43(:,1)+map4(1),inlier43(:,2)+map4(2),inlier43(:,3)+map3(1),inlier43(:,4)+map3(2)];

dx=round((sum(inlier43(:,3))-sum(inlier43(:,1)))/length(inlier43));
dy=round((sum(inlier43(:,4))-sum(inlier43(:,2)))/length(inlier43));
map4=[map4(1)+dx,map4(2)+dy];
mid4=[mid4(1)+dx,mid4(2)+dy];

mask3=zeros(x3,y3);
for i=1:x3
    for j=1:y3
        if(Im3(i,j,1)>0 |Im3(i,j,2)>0 |Im3(i,j,3)>0 )
        mask3(i,j)=1;
        end
    end
end

mask4=zeros(x4,y4);
for i=1:x4
    for j=1:y4
        if(Im4tr(i,j,1)>0 |Im4tr(i,j,2)>0 |Im4tr(i,j,3)>0 )
        mask4(i,j)=2;
        end
    end
end



mask43(map4(1):map4(1)+x4-1,map4(2):map4(2)+y4-1)=mask4;
mask43(map3(1):map3(1)+x3-1,1:y3)=mask43(map3(1):map3(1)+x3-1,1:y3)+1;

temp(:,:,1)=zeros(map3(1),y3);
temp(:,:,2)=zeros(map3(1),y3);
temp(:,:,3)=zeros(map3(1),y3);

Im3_=[temp;Im3;temp];
temp=zeros(size(Im4tr));
Image34=appendimages(Im3_,temp);
a=map4(1);
b=map4(2);
[c d k]=size(Im4tr);

Image34(a:a+c-1,b:b+d-1,:)=Image34(a:a+c-1,b:b+d-1,:)+Im4tr;


[x y]=size(mask43);
for i=1:x
    for j=1:y
        if(mask43(i,j)==3)
            Image34(i,j,:)=Im3_(i,j,:);
        end
    end
   
end  

i=map3(1);
for j=map4(2):size(Im3,2)
   Image34(i,j)=(Image34(i-1,j)+Image34(i+1,j))/4+Image34(i,j)/2;
end
i=size(Im3,1)+map3(1)-1;
for j=map4(2):size(Im3,2)
   Image34(i,j)=(Image34(i-1,j)+Image34(i+1,j))/4+Image34(i,j)/2;
end

j=size(Im3,2);
for j=map3(1):size(Im3,1)+map3;
   Image34(i,j)=(Image34(i,j-1)+Image34(i,j+1))/4+Image34(i,j)/2;
end



imwrite(Image34,'Image34.jpg');

%===============================================================
Matche2=match('IMG2.jpg','IMG3.jpg');
[H23, inlier23]=RANSAC(Matche2);
%clear Matche2
Im2=imread('IMG2.jpg');
Im3=imread('IMG3.jpg');
Im2tr=imtransform(Im2,maketform('affine',H23'));
imwrite(Im2tr,'IMG2tr.jpg')

[x2 y2 z]=size(Im2tr);
[x3 y3 z]=size(Im3);
mask23=zeros(x2+(x3/2),y2+y3);
mid2=[size(Im2,1)/2,size(Im2,2)/2,1]*H23;
mid2=mid2(1,1:2);
mid3=[x3/2,y3/2];
map2=[0,0];
map3=[0,y2];
mid2=mid2+map2;
mid3=mid3+map3;

inlier23=[inlier23(:,1)+map2(1),inlier23(:,2)+map2(2),inlier23(:,3)+map3(1),inlier23(:,4)+map3(2)];

dx=round((sum(inlier23(:,1))-sum(inlier23(:,3)))/length(inlier23));
%inlier12(:,3)=inlier12(:,3)+dx;

dy=round((sum(inlier23(:,2))-sum(inlier23(:,4)))/length(inlier23));
%inlier12(:,4)=inlier12(:,4)+dy;
%clear inlier12
map3=[map3(1)+dx,map3(2)+dy];
mid3=[mid3(1)+dx,mid3(2)+dy];
map33=[map3(1)-dx,map3(2)+dy];
mid33=[mid3(1)-dx,mid3(2)+dy];

mask3=zeros(x3,y3);
for i=1:x3
    for j=1:y3
        if(Im3(i,j,1)>0 |Im3(i,j,2)>0 |Im3(i,j,3)>0 )
        mask3(i,j)=2;
        end
    end
end

mask2=zeros(x2,y2);
for i=1:x4
    for j=1:y2
        if(Im2tr(i,j,1)>0 |Im2tr(i,j,2)>0 |Im2tr(i,j,3)>0 )
        mask2(i,j)=1;
        end
    end
end



mask23(map2(1):map2(1)+x2-1,1:y2)=mask2;
mask23(map3(1):map3(1)+x3-1,map3(2):map3(2)+y3-1)=mask23(map3(1):map3(1)+x3-1,map3(2):map3(2)+y3-1)+2;


%mask12=mask1+mask2;

%clear Im1 inlier12 inlier1 inlier2 mask1 mask2 
%clear Match1
%[l1 l2]=size(mask12);

%attach(Im2tr,Im3,mask23,mid2,mid3,map2,map3,'Image23.jpg');
clear temp
[x y]=size(mask23);

temp(:,:,1)=zeros(map2(1),y2);
temp(:,:,2)=zeros(map2(1),y2);
temp(:,:,3)=zeros(map2(1),y2);

Im2_=[temp;Im2tr;temp];
temp=zeros(size(Im3));
Image23=appendimages(Im2_,temp);
a=map3(1);
b=map3(2);
[c d k]=size(Im3);
Image23(a:a+c-1,b:b+d-1,:)=Im3;

%attach(Im3_,Im4tr,mask43,mid3,mid4,map3,map4,'Image34.jpg');