function toolMarkCB(h, varargin) 

evalin('base', 'delete(hpolys);');%�ٴε���찴ťʱɾ��ͼ��
evalin('base', 'himg = imshow(im1);');%������ذ���ɫ��ťʱ�����Ҳ�ͼ��δɾ������
title({'Background', 'press blue tool button to compute blended image'});

set(h, 'Enable', 'off');

hp1 = impoly(subplot(121));
hp1.setVerticesDraggable(false);%���õ㲻������
addNewPositionCallback(hp1,@toolPasteCB);%����ʵʱ����

hp2 = impoly(subplot(122), hp1.getPosition);
hp2.setVerticesDraggable(false);
addNewPositionCallback(hp2,@toolPasteCB);

assignin('base', 'hpolys', [hp1; hp2]);

set(h, 'Enable', 'on');
