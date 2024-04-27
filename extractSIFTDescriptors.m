function descriptors = extractSIFTDescriptors(image, keypoints)
    if size(image, 3) == 3
        image = rgb2gray(image);
    end
    image = im2double(image);
    scales = unique(keypoints(:, 3));
    gaussianWindows = cell(numel(scales), 1);
    for i = 1:numel(scales)
        gaussianWindows{i} = fspecial('gaussian', [16 16], 1.5 * scales(i));
    end
    descriptors = zeros(size(keypoints, 1), 128); 
    for i = 1:size(keypoints, 1)
        keypoint = keypoints(i, :);
        x = keypoint(1);
        y = keypoint(2);
        scaleIndex = find(scales == keypoint(3));
        if x <= 8 || y <= 8 || x > size(image, 2) - 8 || y > size(image, 1) - 8
            continue;
        end
        orientation = mod(keypoint(4), 360);
        [mag, ang] = computeGradient(image, x, y, keypoint(3));
        ang = mod(ang - orientation, 360);
        mag = mag .* gaussianWindows{scaleIndex};
        descriptor = zeros(1, 128);
        for subX = 0:3
            for subY = 0:3
                binIndex = subY * 4 + subX;
                subMag = mag(subY*4+(1:4), subX*4+(1:4));
                subAng = ang(subY*4+(1:4), subX*4+(1:4));
                hist = zeros(1, 8);
                for b = 0:7
                    binMask = subAng >= b*45 & subAng < (b+1)*45;
                    hist(b+1) = sum(subMag(binMask));
                end
                descriptor(binIndex*8+(1:8)) = hist;
            end
        end
        descriptor = descriptor / norm(descriptor);
        descriptor(descriptor > 0.2) = 0.2;
        descriptor = descriptor / norm(descriptor);
        descriptors(i, :) = descriptor;
    end
end