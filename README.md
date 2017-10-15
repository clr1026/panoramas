# panoramas
Implement Panoramic Image Stitching using Invarient Features
using Matlab   @2009

keypoint matching (match.c and util.c) from David Lowe (lowe@cs.ubc.ca)


Algorithm :
Input: in this project I chose 4 ordered images
       For each pair of images
         I. Extract SIFT features from images
        II. Find geometrically consistent feature matches using RANSAC to solve homography between pairs of images
       III. Find connected components of image matches
Output: Panoramic image
