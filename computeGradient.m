function [mag, ang] = computeGradient(image, x, y, scale)
    windowSize = 16;
    halfWindowSize = windowSize / 2;
    x = round(x);
    y = round(y);
    paddedImage = padarray(image, [halfWindowSize halfWindowSize], 'replicate');
    xPad = x + halfWindowSize;
    yPad = y + halfWindowSize;
    window = paddedImage(yPad-halfWindowSize+1:yPad+halfWindowSize, xPad-halfWindowSize+1:xPad+halfWindowSize);
    [Gx, Gy] = imgradientxy(window, 'sobel');
    [mag, ang] = imgradient(Gx, Gy);
end