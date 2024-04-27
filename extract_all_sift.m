function extract_all_sift(imageFolder, outputFolder) %run extract_all_sift("../data/query_cropped", "./out/query_cropped_features") and extract_all_sift("../data/gallery", "./out/gallery_features_2")
    fprintf("Extracting SIFT descriptors from %s to %s\n", imageFolder, outputFolder);
    verifyFolder(imageFolder, true);
    prepareOutputFolder(outputFolder);
    imgFiles = dir(fullfile(imageFolder, '*.jpg'));
    tic;
    if isempty(gcp('nocreate'))
        parpool;
    end
    parfor i = 1:length(imgFiles)
        processImage(imgFiles(i), imageFolder, outputFolder);
    end
    totalTime = toc;
    fprintf('Total time used: %.2f seconds.\n', totalTime);
end
function verifyFolder(folderPath, isImageFolder)
    if ~exist(folderPath, 'dir')
        if isImageFolder
            error('The image folder does not exist.');
        else
            mkdir(folderPath);
        end
    end
end
function prepareOutputFolder(outputFolder)
    if exist(outputFolder, 'dir')
        clearFolderContents(outputFolder);
    else
        mkdir(outputFolder);
    end
end
function clearFolderContents(folderPath)
    fileList = dir(fullfile(folderPath, '*'));
    for i = 1:length(fileList)
        if ~strcmp(fileList(i).name, '.') && ~strcmp(fileList(i).name, '..')
            fullPath = fullfile(folderPath, fileList(i).name);
            if fileList(i).isdir
                rmdir(fullPath, 's');
            else
                delete(fullPath);
            end
        end
    end
end
function processImage(file, imageFolder, outputFolder)
    try
        imagePath = fullfile(imageFolder, file.name);
        [~, imageName, ~] = fileparts(imagePath);
        outputSubFolder = fullfile(outputFolder, imageName);
        verifyFolder(outputSubFolder, false);
        run(imagePath, outputSubFolder);
    catch ME
        fprintf('Error %s: ', getReport(ME));
    end
    fprintf('Processed %s\n', file.name);
end
function run(imagePath, outputSubFolder)
    [~, imageName, ext] = fileparts(imagePath);
    if ~exist(outputSubFolder, 'dir')
        mkdir(outputSubFolder);
    end
    imageName = regexprep(imageName, '[^a-zA-Z0-9]', '_');
    outputJpgPath = fullfile(outputSubFolder, strcat(imageName, '.jpg'));
    outputMatPath = fullfile(outputSubFolder, strcat(imageName, '.mat'));
    outputJpgPath = string(outputJpgPath);
    outputMatPath = string(outputMatPath);
    try
        image = imread(imagePath);
        keypoints = detectKeypoints(image);
        descriptors = extractSIFTDescriptors(image, keypoints);
        fprintf('Image name: %s\n', imageName);
        figHandle = figure('visible', 'off');
        imshow(image); hold on;
        plot(keypoints(:, 1), keypoints(:, 2), 'r.', 'MarkerSize', 15);
        title('Detected Keypoints'); hold off;
        saveas(figHandle, outputJpgPath, 'jpeg');
        close(figHandle);
        save(outputMatPath, 'keypoints', 'descriptors', '-v7');
    catch ME
        disp(['Error processing image ', imageName, ext, ': ', ME.message]);
    end
end
function checkPathLength(path)
    if length(path) > 260
        error('The output file path is too long: %s', path);
    end
end