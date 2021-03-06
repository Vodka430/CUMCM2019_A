%% 计算某一喷油嘴开启时间间隔及高压油泵角速度下高压油管压强变化
function [p,sum]=module3(detaT,w,x)
%% 数据初始化
A=pi*0.7^2;
dt=0.01;
p(1,1)=100;               %高压油泵内初始压强与密度 
p(2,1)=0.85;
pzuo(1,1)=0.5;
pzuo(2,1)=0.8043;
C=0.85;
V=pi*5^2*500;
num=2000/dt;
thea=zeros(1,num);
h=zeros(1,num);
v=zeros(1,num);
mzuo=zeros(1,num);
thea(1)=pi;
h(1)=-2.413*sin(-1*thea(1)+4.712)+4.826;
v(1)=114.7583;
mzuo(1)=v(1)*pzuo(2,1);
T=roundn(2*pi/w,-2);       %计算高压油泵运动周期，并周期性补油
for i=1:num-1
    dthea=w*dt;
    thea(i+1)=thea(i)+dthea;
    h(i+1)=-2.413*sin(-1*thea(i+1)+4.712)+4.826;    %计算柱状腔下一时刻活塞运动高度
    if pzuo(1,i)>p(1,i)
        dQzuo=C*A*sqrt(2*(pzuo(1,i)-p(1,i))/pzuo(2,i))*dt;       %如果高压油泵内压强大于高压油管内压强，高压油泵排油
    end
    if pzuo(1,i)<=p(1,i)
        dQzuo=0;
    end
    if mod(i*dt,T)==0
        pzuo(1,i+1)=0.5;
        pzuo(2,i+1)=0.8043;                 %如果高压油泵运转完一个完整的周期，进行补油，参数恢复初始化的值
        mzuo(i+1)=v(1)*pzuo(2,1);
        v(i+1)=114.7583;
    end
    if mod(i*dt,T)~=0
    v(i+1)=20+(7.239-h(i+1))*2.5^2*pi;
    mzuo(i+1)=mzuo(i)-dQzuo*pzuo(2,i);
    pzuo(2,i+1)=mzuo(i+1)/v(i+1);                    %如果高压油泵未运转完一个完整的周期，计算高压油泵下一时刻各参数
    Ezuo=645.4*exp(0.00671*pzuo(1,i))+905.6;
    pzuo(1,i+1)=pzuo(1,i)+Ezuo/pzuo(2,i)*(pzuo(2,i+1)-pzuo(2,i));
    end
    m=mod((i-1)*dt,100);             %确定针阀的工作状态
    pos=floor(100*m+1);
    needle_A1=x(pos,2);               %得到喷油嘴此时的出油小孔面积
    if (i-1)*dt-detaT<0
        o=0;                         
    end                              %确定新加喷油嘴的工作状态
    if (i-1)*dt-detaT>=0
        o=(i-1)*dt-detaT;
    end
    n=mod(o,100);
    pos=floor(100*n+1);
    needle_A2=x(pos,2);                    %计算新开喷油嘴喷油量
    dQyou1=C*needle_A1*sqrt(2*(p(1,i)-0.103)/p(2,i))*dt;
    dQyou2=C*needle_A2*sqrt(2*(p(1,i)-0.103)/p(2,i))*dt;      
    dQyou=dQyou1+dQyou2;                            %计算总喷油量
    p(2,i+1)=p(2,i)+(dQzuo*pzuo(2,i)-dQyou*p(2,i))/V;
    Eguan=645.4*exp(0.00671*p(1,i))+905.6;              %更新下一时刻高压油管压强及密度
    p(1,i+1)=p(1,i)+Eguan/p(2,i)*(p(2,i+1)-p(2,i));
end
sum=var(p(1,:));                                 %计算该参数下高压油管内压强波动方差
    
