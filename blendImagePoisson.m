function imret = blendImagePoisson(im1, im2, roi, targetPosition)
%% input: im1 (background), im2 (foreground), roi (in im2), targetPosition (in im1)
tic;

%% ׼������
roi=[roi(:,2),roi(:,1)];%ԭͼ����λ�á�x��h��,��y��w��(ע��˴������roi������x��y������)
targetPosition=[targetPosition(:,2),targetPosition(:,1)];%��ͼ����λ��
d_c=ceil(targetPosition(1,:)-roi(1,:));%�ı�λ��
h1=size(im2,1);
h2=size(im1,1);
imret = im1;

%% �������ΰ�Χ����
hp1=evalin('base', 'hpolys(1)');
w=createMask(hp1);%λ�þ���0Ϊ�����⣬1Ϊ��
w_bo=edge(w);
w(intersect(find(w==1),find(w_bo==1)))=0;
w=w+2*w_bo;%λ�þ���0Ϊ���⣬1Ϊ���ڣ�2Ϊ���߽�
p=find(w==1);
n_p=size(p,1);

%% ����ϵ������A��������Cholesky�ֽ����L
map=zeros(1,n_p);
map(p)=1:n_p;%��λ�þ���w�н��ڵ�˳����ű��ڶ�Ӧ����

A_x=1:n_p;
A_y=1:n_p;
A_s=4*ones(1,n_p);
q_list=[-1,1,-h1,h1];
for i=1:4
    q=p+q_list(i);
    q_in=w(q)==1;%�߼�������q�ڦ�����Ϊ1
    
    A_x_add=1:n_p;
    A_x_add=A_x_add(q_in);
    A_y_add=map(q(q_in));
    A_s_add=-ones(1,n_p);
    A_s_add=A_s_add(q_in);
    A_x=[A_x,A_x_add];
    A_y=[A_y,A_y_add];
    A_s=[A_s,A_s_add];
end
A=sparse(A_x,A_y,A_s,n_p,n_p);%ϵ�����󴢴�

L=chol(A);

%% ���㳣����b
[x1,y1]=find(w==1);%Դͼ�ж�Ӧ�ڵ�λ��
p1=p;%Դͼ�ж�Ӧ�ڵ����
xy2=[x1,y1]+d_c;%Ŀ��ͼ�ж�Ӧ��λ��
x2=xy2(:,1);
y2=xy2(:,2);
p2=x2+(y2-1)*h2;%Ŀ��ͼ�ж�Ӧ�ڵ����

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
        miu=15;%�˴�����͸��Ч���뱳�������ȵĹ�ϵ
        pq_changelist=abs(f_pq_star)>abs(g_pq)*miu;
        %v_pq(pq_changelist)=f_pq_star(pq_changelist);
        b(:,i)=b(:,i)+v_pq;
    end
end

%% ����f_p�������ͼ��
f_p=(L\(L'\b));
f_p=uint8(f_p);

for i=1:3
    for j=1:n_p
        imret(x2(j),y2(j),i)=f_p(j,i);
    end
end

toc;
end