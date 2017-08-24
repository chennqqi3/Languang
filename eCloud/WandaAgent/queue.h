#ifndef __QUEUE_H__
#define __QUEUE_H__

#include "BasicDefine.h"

typedef struct node 
{
    int     len;
    char   *data;
    
    struct node *next;
} NODE;


typedef struct mqueue
{
    NODE    *head;
    NODE    *tail;
    int      max_len;
    int      len;
    pthread_mutex_t lock;
} mqueue;

mqueue* mq_create(int maxsize);
int mq_push(mqueue *q, NODE *src);
int mq_pop(mqueue *q, NODE *dst);
int mq_destroy(mqueue *q);
int mq_reset(mqueue *q);
int mq_len(mqueue *q);
int mq_empty(mqueue *q);
int mq_free_node(NODE *p);




#endif
