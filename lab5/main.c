/*
    Lab5: apply given convolution matrix to an image
    test site used: https://www.photo-kako.com/en/convolution/
    good explaining video: https://www.youtube.com/watch?v=8rrHTtUzyZA
*/

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>

#define STB_IMAGE_IMPLEMENTATION
#include "stb/stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb/stb_image_write.h"

#include "bmpimage.h"


/*
    Load image from file and return result
*/
BMPImage *loadim(const char *filename) {
    // check if file exists
    if (access(filename, F_OK) != 0) {
        fputs("Input file doesn't exist", stderr);
        return NULL;
    }

    // try to alloc image struct
    BMPImage *img = malloc(sizeof(BMPImage));
    if (img == NULL) {
        fputs("Allocation error", stderr);
        return NULL;
    }

    // load image data
    img->data = stbi_load(filename, &(img->width), &(img->height), &(img->channels), 0);
    if (img->data == NULL) {
        fputs("Error while loading image", stderr);
        free(img);
        return NULL;
    }

    return img;
}


/*
    Save image to file
*/
int saveim(const char *filename, BMPImage *img) {
    // create file if not existed
    int fd = 0;
    if ((fd = open(filename, O_CREAT | O_WRONLY | O_TRUNC, 0644)) == -1){
        fputs("Error opening output file", stderr);
		return 1;
	}
	close(fd);

    // dump image data
    stbi_write_bmp(filename, img->width, img->height, img->channels, img->data);

    return 0;
}


/// Expand image (add external border with values copied)
BMPImage *expandim(BMPImage *img) {
    // allocate image
    BMPImage *res = malloc(sizeof(BMPImage));
    if (res == NULL) {
        fputs("Allocation error", stderr);
        return NULL;
    }

    // set image info
    res->width = img->width + 2;
    res->height = img->height + 2;
    res->channels = img->channels;

    // allocate image data
    res->data = malloc(res->width * res->height * res->channels * sizeof(unsigned char));
    if (res->data == NULL) {
        fputs("Allocation error", stderr);
        free(res);
        return NULL;
    }

    ////////////////// COPY CORE //////////////////
    {
        // start offset in res
        const int START = (res->width + 1) * res->channels;

        // padding per new line in res
        const int PAD = 2 * res->channels;

        // amount of array elements in line of img
        const int LINE = img->width * img->channels;

        for (int i = 0; i < LINE * img->height; ++i) {
            int lines = i / LINE;
            res->data[START + PAD * lines + i] = img->data[i];
        }
    }

    ////////////////// CLONE UPPER AND BOTTOM LINES //////////////////
    {
        // start offset in res
        const int START_TOP = res->channels;
        const int START_BOTTOM = res->width * (res->height - 1) * res->channels + res->channels;

        // bottom offset for img
        const int PAD = img->width * (img->height - 1) * img->channels;

        for (int i = 0; i < img->width * img->channels; ++i) {
            // top
            res->data[START_TOP + i] = img->data[i];
            
            // bottom
            res->data[START_BOTTOM + i] = img->data[PAD + i];
        }
    }

    ////////////////// CLONE RIGHT AND LEFT LINES //////////////////
    {
        // line offset
        const int PAD_RES = res->width * res->channels;
        const int PAD_IMG = img->width * img->channels;

        // start offset for left side
        const int START_RES = 2 * PAD_RES - res->channels;
        const int START_IMG = PAD_IMG - img->channels;

        for (int i = 0; i < img->height; ++i) 
            for (int c = 0; c < img->channels; ++c){
                // left
                res->data[PAD_RES + i * PAD_RES + c] = img->data[i * PAD_IMG + c];
            
                // right
                res->data[START_RES + i * PAD_RES + c] = img->data[START_IMG + i * PAD_IMG + c];
        }
    }

    ////////////////// CLONE CORNERS //////////////////
    {
        for (int c = 0; c < img->channels; ++c) {
            // top left
            res->data[c] = img->data[c];

            // top right
            res->data[(res->width - 1) * res->channels + c] = img->data[(img->width - 1) * img->channels + c];

            // bottom left
            res->data[res->width * (res->height - 1) * res->channels + c] = img->data[img->width * (img->height - 1) * img->channels + c];

            // bottom right
            res->data[res->width * res->height * res->channels - res->channels + c] = img->data[img->width * img->height * img->channels - img->channels + c];
        }
    }

    return res;
}

extern void applym(BMPImage *, BMPImage *, const double[3][3]);

/// Free image loaded using stbi
void free_stbi(BMPImage *img) {
    stbi_image_free(img->data);
    free(img);
}


/// Free customly allocated image
void free_img(BMPImage *img) {
    free(img->data);
    free(img);
}


/// Main function - call others in order
int main(int argc, char **argv) {
    // check arguments
    if (argc != 3) {
        fprintf(stderr, "Usage: %s [input file] [output file]\n", argv[0]);
        return 1;
    }

    // load image
    BMPImage *img = loadim(argv[1]);
    if (img == NULL)
        return 1;

    // upscale image
    BMPImage *expanded = expandim(img);
    if (expanded == NULL) {
        free_stbi(img);
        return 1;
    }

    // apply convolution matrix
    const double conv_matrix[3][3] = {
        {0.0625, 0.125, 0.0625},
        {0.125, 0.25, 0.125},
        {0.0625, 0.125, 0.0625}
    };
    applym(expanded, img, conv_matrix);
    
    // save
    int retcode = saveim(argv[2], img);

    // free all data
    free_img(expanded);
    free_stbi(img);

    return retcode;
}