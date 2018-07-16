images=dir('/home/shyamgopal/CVIT/tracking/Skater/img/*.jpg');
videoPlayer = vision.VideoPlayer('Position',[100,100,680,520]);
videoFWriter = vision.VideoFileWriter('myFile.avi');

img1=imread(strcat('./Skater/img/',images(1).name));
objectFrame = img1;
figure; imshow(objectFrame);

objectRegion=round(getPosition(imrect))

objectImage = insertShape(objectFrame,'Rectangle',objectRegion,'Color','red'); 
figure;
imshow(objectImage);
title('Red box shows object region');

points = detectMinEigenFeatures((objectFrame),'ROI',objectRegion);

pointImage = insertMarker(objectFrame,points.Location,'+','Color','white');
fh=figure;
imshow(pointImage);
title('Detected interest points');

tracker = vision.PointTracker('MaxBidirectionalError',1);

initialize(tracker,points.Location,objectFrame);

for i=2:size(images,1)
	img=imread(strcat('./Skater/img/',images(i).name));
    frame = img;
    [points,validity] = tracker(frame);
    minx=2000;
    miny=2000;
    maxx=0;
    maxy=0;
    for j=1:size(points,1)
    	if validity(j)==1
    		if points(j,1)>maxx
    			maxy=points(j,1);
    		end

    		if points(j,1)<minx
    			minx=points(j,1);
    		end

    		if points(j,2)>maxy
    			maxy=points(j,2);
    		end

    		if points(j,2)<miny
    			miny=points(j,2);
    		end

    	end
    end

    out = insertMarker(frame,points(validity, :),'+');
    obbjectRegion=[minx,miny,abs(maxx-minx),abs(maxy-miny)];

    newpoints = detectMinEigenFeatures((frame),'ROI',objectRegion);
    if i%5==0
        tracker = vision.PointTracker('MaxBidirectionalError',1);
    end
    initialize(tracker,newpoints.Location,img);
    step(videoFWriter,out);



    
    
    videoPlayer(out);
    fname=strcat('./output/',string(i),'.jpg');
    %imwrite(out,fname);
end

release(videoPlayer);
release(videoFWriter);

