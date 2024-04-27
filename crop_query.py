import cv2
import numpy as np
import os
def query_crop(query_path, txt_path, save_path):
    query_img = cv2.imread(query_path)
    query_img = query_img[:,:,::-1]
    txt = np.loadtxt(txt_path)
    crop = query_img[int(txt[1]):int(txt[1] + txt[3]), int(txt[0]):int(txt[0] + txt[2]), :]
    cv2.imwrite(save_path, crop[:,:,::-1])
    print('cropped file saved to: ', save_path)
    return crop

def main():
        query_folder = './data/query/'
        txt_folder = './data/query_box/'
        save_folder = './data/query_cropped/'
        for query_file in os.listdir(query_folder):
            query_path = os.path.join(query_folder, query_file)
            txt_path = os.path.join(txt_folder, query_file.replace('.jpg', '.txt'))
            save_path = os.path.join(save_folder, query_file)
            query_crop(query_path, txt_path, save_path)

if __name__ == '__main__':
    main()