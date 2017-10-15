function [ H,newinlier ] = RANSAC( Matches )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


count=0;
count0=0;
num=length(Matches);
N=500;

while (count0< num & N>0)
    N=N-1;
   % display (count0);
    
    % select 4 set of matches at random
    index = ceil(rand(1,4) * num); 
    x1 = Matches(index,1);
    y1 = Matches(index,2);
    x2 = Matches(index,3);
    y2 = Matches(index,4);


    % Compute transformation
    %   Construct a matrix A and vector b  (AX=b)    (x=[m1;m2;m3;m4;t1;t2])
    %   Solve for the unknown transformation parameters P using x=pinv(A)*b

    % trans=[m1;m2;m3;m4;t1;t2];
    A1=[Matches(index,1:2),zeros(4,2),ones(4,1),zeros(4,1)];
    A2=[zeros(4,2),Matches(index,1:2),zeros(4,1),ones(4,1)];

    A=[A1(1,:);A2(1,:);A1(2,:);A2(2,:);A1(3,:);A2(3,:);A1(4,:);A2(4,:)];
    B=[x2(1);y2(1);x2(2);y2(2);x2(3);y2(3);x2(4);y2(4)];
    P=pinv(A)*B;

    % Find inliers to this transformation
    %  1 Using the transformation parameters P, transform all match points in image 1.
    %    Count the number of inliers, 
    %       inliers defined as # of transformed points from image 1 
    %       that lie within a radius of 10 pixels of their pair in image 2.
    %  2 If this count exceeds the best total so far, save the transformation
    %    parameters and the set of inliers (points in image1)
    %  3 Perform a final refit using the set of inliers belonging to the best 
    %    transformation you found. This refit should use all inliers,
    inlier=[];
    M=[P(1),P(2);P(3),P(4)];
    T=[P(5);P(6)];
    count=0;
    for i=1:num
        pi=M*[Matches(i,1);Matches(i,2)]+T;
        dis=sqrt((pi(1)-Matches(i,3))^2+(pi(2)-Matches(i,4))^2);
        if (dis<=1)
            count=count+1;
            inlier=[inlier; Matches(i,1:4)];
        end
    end

    if(count>=count0)
        count0=count;
        P0=P;
        inlier0=inlier;
    end

end
  
  C_=[];
  % refit all inlier
  %P_=[P0(1),P0(2),0;P0(3),P0(4),0;0,0,1];
  H=[P0(1),P0(2),P0(5);P0(3),P0(4),P0(6);0,0,1];
  for i=1:length(inlier0)
        C=[inlier0(i,1:2),1];
        C_=[C_;C*H];
  end
  
  newinlier=[C_(:,1:2),inlier0(:,3:4)];

% transform image 1 using this final set of transformation parameters P
%   Homography matrix H=[m1 m2 t1;m3 m4 t2; 0 0 1]
%   using the imtransform and maketform functions as follows:
%   transformed image=imtransform(im1,maketform(¡¦affine¡¦,H¡¦));
% 

H=[P0(1),P0(2),P0(5);P0(3),P0(4),P0(6);0,0,1];

%clear inlier inlier0 Matches
%inlier = [newinlier(:,1:2),newinlier(:,5:6)];



end

