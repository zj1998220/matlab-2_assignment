function toolMarkCB(h, varargin) 

evalin('base', 'delete(hpolys);');%再次点击红按钮时删除图形
evalin('base', 'himg = imshow(im1);');%解决了重按红色按钮时出现右侧图像未删除现象
title({'Background', 'press blue tool button to compute blended image'});

set(h, 'Enable', 'off');

hp1 = impoly(subplot(121));
hp1.setVerticesDraggable(false);%设置点不可拉伸
addNewPositionCallback(hp1,@toolPasteCB);%加入实时变形

hp2 = impoly(subplot(122), hp1.getPosition);
hp2.setVerticesDraggable(false);
addNewPositionCallback(hp2,@toolPasteCB);

assignin('base', 'hpolys', [hp1; hp2]);

set(h, 'Enable', 'on');
