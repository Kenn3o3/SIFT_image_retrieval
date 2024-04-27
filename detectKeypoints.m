function keypoints = detectKeypoints(image)
    numOctaves = 4;
    numScales = 5;
    octaveInitialSigma = 1.6;
    contrastThreshold = 0.01;
    keypoints = [];
    sigma = octaveInitialSigma * sqrt(2).^((0:numScales-1)/(numScales-1));
    [gaussianPyramid, dogPyramid] = constructScaleSpace(image, numOctaves, numScales, octaveInitialSigma);
    for o = 1:numOctaves
        for s = 2:numScales-2
            currentDogImage = dogPyramid{o, s};
            below = dogPyramid{o, s-1};
            above = dogPyramid{o, s+1};
            for y = 2:size(currentDogImage, 1)-1
                for x = 2:size(currentDogImage, 2)-1
                    patch = currentDogImage(y-1:y+1, x-1:x+1);
                    patchBelow = below(y-1:y+1, x-1:x+1);
                    patchAbove = above(y-1:y+1, x-1:x+1);
                    block = cat(3, patchBelow, patch, patchAbove);
                    [maxVal, maxIdx] = max(block(:));
                    [minVal, minIdx] = min(block(:));
                    if ((maxIdx == 14 && maxVal >= contrastThreshold) || (minIdx == 14 && minVal <= -contrastThreshold))
                        keypoints = [keypoints; x, y, sigma(s), o];
                    end
                end
            end
        end
    end
end