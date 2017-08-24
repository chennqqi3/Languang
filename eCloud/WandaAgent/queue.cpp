#include "queue.h"

mqueue* mq_create(int maxsize)
{
    NODE *p = NULL;
    mqueue *q = (mqueue*)malloc(sizeof(mqueue));
    if (q == NULL) return NULL;

    q->max_len = maxsize;
    q->len = 0;

    p = (NODE *)malloc(sizeof(NODE));
    if (p == NULL) 
    {
        free(q);
		q = NULL;
        return NULL;
    }

    p->next = NULL;
    p->data = NULL;
	p->len  = 0;

    q->head = q->tail = p;
    pthread_mutex_init(&q->lock, NULL);

    return q;
}

int mq_push(mqueue *q, NODE *src)
{
    NODE* dst = NULL;
    NODE* p = NULL;

    if(q->len >= q->max_len)
    {
        return -1;
    }
    
    pthread_mutex_lock(&q->lock);

    dst = q->head;
    dst->len = src->len;
    dst->data = (char *)malloc(src->len*sizeof(char));
    if (dst->data == NULL)
    {
        pthread_mutex_unlock(&q->lock);
        return -2;
    }

    memcpy(dst->data, src->data, src->len);

    p = (NODE *)malloc(sizeof(NODE));
    if (p == NULL)
    {
        free(dst->data);
		dst->data = NULL;
        pthread_mutex_unlock(&q->lock);
        return -2;
    }

    p->next = NULL;
    p->data = NULL;
	p->len  = 0;
    dst->next = p;
    q->head = p;
    q->len++;
    
    pthread_mutex_unlock(&q->lock);
    return 0;
}

// return 0: empty
//       -1: fail
//        1: success
int mq_pop(mqueue *q, NODE *dst)
{
   NODE *src = q->tail;    

    if( mq_empty(q) < 0)
    {
        return 0;
    }
    
    pthread_mutex_lock(&q->lock);
    dst->len = src->len;
    memcpy(dst->data, src->data, src->len);
        
    q->tail = src->next;
    mq_free_node(src);
    q->len -= 1;
    pthread_mutex_unlock(&q->lock);
        
    return 1;
}

int mq_destroy(mqueue *q)
{
    if (q)
    {
        mq_reset(q);
    }

    mq_free_node(q->head);
	pthread_mutex_destroy(&q->lock);
    free (q);
    q = NULL;
    return 0;
}

int mq_reset(mqueue *q)
{
    NODE *p, *t;
    if(!q || q->len == 0)
    {
        return -1;
    }
    
    pthread_mutex_lock(&q->lock);
    p = q->tail;
  
    while(p!= q->head)
    {
        t = p;
        p = p->next;
        mq_free_node(t);
    }

    q->tail = q->head;
    q->len = 0;
    pthread_mutex_unlock(&q->lock);

    return 0;
}

int mq_len(mqueue *q)
{
    return q->len;
}

int mq_empty(mqueue *q)
{
    if (q->len <= 0)
        return 1;
    else
        return 0;
}

int mq_free_node(NODE *p)
{
    if (p == NULL) return -1;
    if (p->data != NULL) free (p->data);
	p->data = NULL;
	p->len  = 0;
    free (p);
	p = NULL;
    return 0;
}
