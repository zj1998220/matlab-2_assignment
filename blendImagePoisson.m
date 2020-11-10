function imret = blendImagePoisson(im1, im2, roi, targetPosition)
%% input: im1 (background), im2 (foreground), roi (in im2), targetPosition (in im1)
tic;

%% 准备工作
roi=[roi(:,2),roi(:,1)];%原图像中位置↓x（h）,→y（w）(注意此处输入的roi与里面x，y的区别)
targetPosition=[targetPosition(:,2),targetPosition(:,1)];%现图像中位置
d_c=ceil(targetPosition(1,:)-roi(1,:));%改变位移
h1=size(im2,1);
h2=size(im1,1);
imret = im1;

%% 计算多边形包围区域
hp1=evalin('base', 'hpolys(1)');
w=createMask(hp1);%位置矩阵：0为区域外，1为内
w_bo=edge(w);
w(intersect(find(w==1),find(w_bo==1)))=0;
w=w+2*w_bo;%位置矩阵：0为Ω外，1为Ω内，2为Ω边界
p=find(w==1);
n_p=size(p,1);

%% 计算系数矩阵A，并计算Cholesky分解矩阵L
map=zeros(1,n_p);
map(p)=1:n_p;%在位置矩阵w中将内点顺序序号标在对应点上

A_x=1:n_p;
A_y=1:n_p;
A_s=4*ones(1,n_p);
q_list=[-1,1,-h1,h1];
for i=1:4
    q=p+q_list(i);
    q_in=w(q)==1;%逻辑矩阵：若q在Ω内则为1
    
    A_x_add=1:n_p;
    A_x_add=A_x_add(q_in);
    A_y_add=map(q(q_in));
    A_s_add=-ones(1,n_p);
    A_s_add=A_s_add(q_in);
    A_x=[A_x,A_x_add];
    A_y=[A_y,A_y_add];
    A_s=[A_s,A_s_add];
end
A=sparse(A_x,A_y,A_s,n_p,n_p);%系数矩阵储存

L=chol(A);

%% 计算常数项b
[x1,y1]=find(w==1);%源图中对应内点位置
p1=p;%源图中对应内点序号
xy2=[x1,y1]+d_c;%目标图中对应点位置
x2=xy2(:,1);
y2=xy2(:,2);
p2=x2+(y2-1)*h2;%目标图中对应内点序号

b=zeros(n_p,3);
q1_list=q_list;
q2_list=[-1,1,-h2,h2];
for i=1:3
    g=double(im2(:,:,i));
    f_star=double(im1(:,:,i));
    for j=1:4
        q1=p1+q1_list(j);
        q2=p2+q2_list(j);
        q1_bo=w(q1)==2;
        b(q1_bo,i)=b(q1_bo,i)+f_star(q2(q1_bo));
        
        f_pq_star=f_star(p2)-f_star(q2);
        g_pq=g(p1)-g(q1);
        v_pq=g_pq;
        miu=15;%此处控制透明效果与背景清晰度的关系
        pq_changelist=abs(f_pq_star)>abs(g_pq)*miu;
        %v_pq(pq_changelist)=f_pq_star(pq_changelist);
        b(:,i)=b(:,i)+v_pq;
    end
end

%% 计算f_p，并输出图像
f_p=(L\(L'\b));
f_p=uint8(f_p);

for i=1:3
    for j=1:n_p
        imret(x2(j),y2(j),i)=f_p(j,i);
    end
end

toc;
end