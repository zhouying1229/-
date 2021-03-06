%无标度网络的构建
N=input('请输入网络中点的个数：');%最终网络中点的个数
k=input('请输入平均度：');
m0=5;%初始随机网络有10个节点
alpha=input('请输入阈值分布平均程度α（0<α<1，越小越平均）：');
beta=input('请输入能力容许参数β：');
p=input('请输入初始失效点比例：');
%无标度网络的建立
A=wubiaodu(N,k,m0);

%损失矩阵 风险矩阵等
V=0;
loss=[2 3 4 2 1 2 2];
risk=[0.7 0.3 0.1 0.9 0.9 0.3 0.3];
for i=1:7
    V=V+loss(i)*risk(i);
end
risk_interaction=[0.6 0.1 0.05 0.4 0.35 0.35 0.35;0.2 0.6 0.1 0.35 0.3 0.3 0.3;0.35 0.4 0.6 0.3 0.25 0.25 0.25;
    0.1 0.05 0.01 0.6 0.5 0.45 0.45;0.1 0.05 0.01 0.5 0.6 0.4 0.4;0.1 0.05 0.01 0.45 0.5 0.6 0.4;0.1 0.05 0.01 0.45 0.5 0.45 0.6];

%定义风险阈值向量
degree=sum(A);
neighbor=zeros(1,N);
for i=1:N
    for j=1:N
        if A(i,j)~=0
            neighbor(i)=neighbor(i)+degree(j);
        end
    end
end
maxneighbor=zeros(1,N);
for i=1:N
    maxneighbor(i)=(degree(i)*neighbor(i))^alpha;
end
C=zeros(1,N);
for i=1:N
    C(i)=beta*V*(degree(i)*neighbor(i))^alpha/max(maxneighbor);
end
% 定义初始负荷向量
pd=zeros(N,7);%初始负荷用于判断风险是否发生的布尔向量
fuhe=zeros(N,1);
m=zeros(N);
for i=1:N
    for j=1:7
        if rand()<risk(j)
            pd(i,j)=1;
            fuhe(i)=fuhe(i)+loss(j);
        end
    end
    while fuhe(i)>=C(i)%如果负荷过大时就删掉一些负荷
          sj=ceil(rand*7);%随机产生一个1到7的随机数
          if (rand()>risk(sj))&&(pd(i,sj)==1)
             fuhe(i)=fuhe(i)-loss(sj);
             pd(i,sj)=0;
          end
     end
end
fuhe
        
%最初 令一部分点失效
cssx=randperm(N);
invalid=cssx(1:(p*N));%随机取失效节点的位置，一共有p*N个失效节点位置
lossqiansan=loss(1)+loss(2)+loss(3);
for i=1:p*N
    if fuhe(invalid(i))-pd(invalid(i),1)*loss(1)-pd(invalid(i),2)*loss(2)-pd(invalid(i),3)*loss(3)+lossqiansan>=C(invalid(i))
        for j=1:3
            if pd(invalid(i),j)==0
               fuhe(invalid(i))=fuhe(invalid(i))+loss(j);
               pd(invalid(i),j)=1;
            end
        end
    else%引发外源性风险后必须失效,否则就换一个节点
       while  fuhe(invalid(i))-pd(invalid(i),1)*loss(1)-pd(invalid(i),2)*loss(2)-pd(invalid(i),3)*loss(3)+lossqiansan<C(invalid(i))
             a=ceil(rand*N);
             if  ismember(a,invalid)==0 && (fuhe(a)-pd(a,1)*loss(1)-pd(a,2)*loss(2)-pd(a,3)*loss(3)+lossqiansan)>=C(a) 
                 fuhe(a)=fuhe(a)-pd(a,1)*loss(1)-pd(a,2)*loss(2)-pd(a,3)*loss(3)+lossqiansan;
                 invalid(i)=a;
                 pd(invalid(i),1)=1;
                 pd(invalid(i),2)=1;
                 pd(invalid(i),3)=1;
             end
        end
   end
end
num_invalid=0;
for i=1:N
    if fuhe(i)>=C(i)
        num_invalid=num_invalid+1;
    end
end
invalid
while num_invalid>0 && num_invalid<0.7*N 
%判断网络是否处于稳定状态
%失效节点的负荷转移
for i=1:num_invalid

%     while fuhe(invalid(i))>0 && sum(A(invalid(i)))>0
        for j=1:7
            if pd(invalid(i),j)==1%对于第invalid(i)节点所负荷的风险
                fuhe(invalid(i))=fuhe(invalid(i))-loss(j)
                pd(invalid(i),j)=0
                   for d=1:N
                      for f=1:7
                          if rand()<risk_interaction(j,f) && ismember(d,invalid)==0 && A(invalid(i),d)==1 && pd(d,f)==0
                             pd(d,f)=1;
                             fuhe(d)=fuhe(d)+loss(f);
                          end
                      end
                   end
            end 
        end
        for d=1:N
           if A(invalid(i),d)==1%对于邻居节点（位置d表示）
               A(invalid(i),d)=0;
           end
        end
end

        

%重新定义失效节点个数和位置
    num_invalid=0;
    for i=1:N
        if fuhe(i)>=C(i)
            num_invalid=num_invalid+1;
        end
    end
    invalid=zeros(1,num_invalid);
    js=1;
    while js-1<num_invalid
        for i=1:N
            if fuhe(i)>=C(i)
               invalid(js)=i;
               js=js+1;
            end
        end
    end
   invalid
end
fuhe