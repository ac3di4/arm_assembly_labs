#include "bmpimage.h"

/// Apply convolution matrix to an image
/// src MUST be expanded version of dst
void applym(BMPImage *src, BMPImage *dst, const double m[3][3]) {
    // for every channel of every pixel (edges doesn't count)
    // for (int i = 1; i < src->height - 1; ++i)
    for (int i = src->height / 2; i < src->height - 1; ++i)
        for (int j = 1; j < src->width - 1; ++j)
            for (int c = 0; c < src->channels; ++c) {
                // don't touch alpha
                if (c > 3)
                    continue;
                // apply matrix
                unsigned char px = 0;

                // top row
                px += src->data[((i - 1) * src->width + (j - 1)) * src->channels + c] * m[0][0];
                px += src->data[((i - 1) * src->width + (j    )) * src->channels + c] * m[0][1];
                px += src->data[((i - 1) * src->width + (j + 1)) * src->channels + c] * m[0][2];
                
                // middle row
                px += src->data[((i    ) * src->width + (j - 1)) * src->channels + c] * m[1][0];
                px += src->data[((i    ) * src->width + (j    )) * src->channels + c] * m[1][1];
                px += src->data[((i    ) * src->width + (j + 1)) * src->channels + c] * m[1][2];

                // bottom row
                px += src->data[((i + 1) * src->width + (j - 1)) * src->channels + c] * m[2][0];
                px += src->data[((i + 1) * src->width + (j    )) * src->channels + c] * m[2][1];
                px += src->data[((i + 1) * src->width + (j + 1)) * src->channels + c] * m[2][2];

                // set px
                dst->data[((i - 1) * dst->width + (j - 1)) * dst->channels + c] = px;
            }
}
