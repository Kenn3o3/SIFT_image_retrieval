function [gaussianPyramid, dogPyramid] = constructScaleSpace(image, numOctaves, numScales, octaveInitialSigma)
    if size(image, 3) == 3
        image = rgb2gray(image);
    end
    image = im2double(image);
    gaussianPyramid = cell(numOctaves, numScales);
    dogPyramid = cell(numOctaves, numScales - 1);
    k = 2^(1/(numScales - 1));
    sigmas = zeros(numScales, 1);
    sigmas(1) = octaveInitialSigma;
    for s = 2:numScales
        sigmas(s) = sigmas(s-1) * k;
    end
    for o = 1:numOctaves
        for s = 1:numScales
            if o == 1 && s == 1
                gaussianPyramid{o, s} = imgaussfilt(image, sigmas(s));
            elseif s == 1
                gaussianPyramid{o, s} = imresize(gaussianPyramid{o-1, 2}, 0.5);
            else
                gaussianPyramid{o, s} = imgaussfilt(gaussianPyramid{o, s-1}, sigmas(s));
            end
        end
    end
    for o = 1:numOctaves
        for s = 1:numScales - 1
            dogPyramid{o, s} = gaussianPyramid{o, s+1} - gaussianPyramid{o, s};
        end
    end
end