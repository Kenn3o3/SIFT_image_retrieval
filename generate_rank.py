import os
import scipy.io
import numpy as np
import shutil
from scipy.spatial.distance import cdist
from scipy.spatial import distance
def compute_similarity(query_descriptors, gallery_descriptors, ratio_threshold=0.8):
    query_descriptors = np.nan_to_num(query_descriptors)
    gallery_descriptors = np.nan_to_num(gallery_descriptors)
    query_descriptors /= (np.linalg.norm(query_descriptors, axis=1, keepdims=True) + 1e-10)
    gallery_descriptors /= (np.linalg.norm(gallery_descriptors, axis=1, keepdims=True) + 1e-10)
    similarities = np.dot(query_descriptors, gallery_descriptors.T)
    sorted_indices = np.argsort(-similarities, axis=1)
    avg_similarity = 0
    good_matches_count = 0
    for i in range(len(query_descriptors)):
        if sorted_indices[i].size > 1:
            closest_similarity = similarities[i, sorted_indices[i][0]]
            second_closest_similarity = similarities[i, sorted_indices[i][1]]
            ratio = second_closest_similarity / (closest_similarity + 1e-10)
            if ratio < ratio_threshold:
                avg_similarity += closest_similarity
                good_matches_count += 1
        elif sorted_indices[i].size == 1:
            closest_similarity = similarities[i, sorted_indices[i][0]]
            avg_similarity += closest_similarity
            good_matches_count += 1
    if good_matches_count > 0:
        avg_similarity /= good_matches_count
    else:
        avg_similarity = 0
    return avg_similarity

def compute_rank_lists(query_folder, gallery_folder, output_folder, top_k=50, output_file="rank_list.txt"):
    rank_list_idx = ['2714', '776', '3557', '2461', '1709', '316', '2176', '1656', '4716', '3906', '35', '1258', '4929', '4445', '27', '2032', '3502', '2040', '4354', '3833']
    if os.path.exists(output_folder):
        shutil.rmtree(output_folder)
    os.makedirs(output_folder, exist_ok=True)
    print("Computing rank lists...")
    print("query_folder: ", query_folder)
    print("gallery_folder: ", gallery_folder)
    print("output_folder: ", output_folder)
    print("top_k: ", top_k)
    print("output_file: ", output_file)
    query_files = [
        os.path.join(dp, f)
        for dp, dn, filenames in os.walk(query_folder)
        for f in filenames
        if f.endswith(".mat")
    ]
    print("number of query files: ", len(query_files))
    gallery_files = [
        os.path.join(dp, f)
        for dp, dn, filenames in os.walk(gallery_folder)
        for f in filenames
        if f.endswith(".mat")
    ]
    print("number of gallery files: ", len(gallery_files))
    rank_list_dict = {}
    for query_file in query_files:
        print("matching query_file: ", query_file)
        query_name = os.path.splitext(os.path.basename(query_file))[0]
        print("query_name: ", query_name)
        query_descriptors = scipy.io.loadmat(query_file)["descriptors"]
        similarities = []
        for gallery_file in gallery_files:
            gallery_descriptors = scipy.io.loadmat(gallery_file)["descriptors"]
            avg_similarity = compute_similarity(query_descriptors, gallery_descriptors)
            gallery_name = os.path.splitext(os.path.basename(gallery_file))[0]
            similarities.append((gallery_name, avg_similarity))
        similarities.sort(key=lambda x: x[1], reverse=True)
        rank_list_dict[query_name] = [x[0] for x in similarities]
        print("rank_list_dict[query_name][:3]: ", rank_list_dict[query_name][:3])
    rank_list_dict = {k: rank_list_dict[k] for k in rank_list_idx} #sorting
    with open(os.path.join(output_folder, output_file), "w") as f:
        for query_name, ranked_gallery_names in rank_list_dict.items():
            query_idx = rank_list_idx.index(query_name)
            f.write(f"Q{query_idx+1}: {' '.join(ranked_gallery_names)}\n")
            query_subfolder = os.path.join(output_folder, query_name)
            os.makedirs(query_subfolder, exist_ok=True)
            original_query_image_path = os.path.join(
                query_folder, query_name, query_name + ".jpg"
            )
            query_image_destination = os.path.join(query_subfolder, query_name + ".jpg")
            shutil.copy(original_query_image_path, query_image_destination)
            print("original_query_image_path: ", original_query_image_path)
            print("query_image_destination: ", query_image_destination)
            for i, gallery_image_name in enumerate(ranked_gallery_names[:top_k]):
                original_gallery_image_path = os.path.join(
                    gallery_folder, gallery_image_name, gallery_image_name + ".jpg"
                )
                gallery_image_destination = os.path.join(
                    query_subfolder, f"top{i+1}_{gallery_image_name}.jpg"
                )
                shutil.copy(original_gallery_image_path, gallery_image_destination)
            print("--------------------")

def main(demo=False):
        # compute_rank_lists(
        #     query_folder="./out/demo/",
        #     gallery_folder="./out/gallery_features/",
        #     output_folder="./match_results/",
        #     top_k=10,
        #     output_file="./rank_list.txt",
        # )
        compute_rank_lists(
            query_folder="./out/query_cropped_features_2/",
            gallery_folder="./out/gallery_features_2/",
            output_folder="./match_results_3/",
            top_k=10,
            output_file="./rank_list_3.txt",
        )
if __name__ == "__main__":
    main(demo=False)
