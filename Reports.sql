 - -   A l l   i t e m s
 S E L E C T   *   F R O M   [ A G O L _ I T E M S ]   o r d e r   b y   n u m V i e w s   d e s c

 - -   I t e m   c o u n t   b y   o w n e r / a c c e s s
 s e l e c t   [ o w n e r ] ,   [ a c c e s s ] ,   c o u n t ( * )   a s   i t e m s   f r o m   [ A G O L _ I T E M S ]   g r o u p   b y   [ o w n e r ] ,   [ a c c e s s ]   o r d e r   b y   o w n e r ,   a c c e s s

 - -   N u m b e r   o f   p u b l i c   i t e m s   b y   o w n e r
 s e l e c t   d . r e g i o n ,   i . [ o w n e r ] ,   c o u n t ( * )   a s   p u b l i c _ i t e m s   f r o m   [ A G O L _ I T E M S ]   a s   i   l e f t   j o i n   D O M A I N I N F O   a s   d   o n   i . [ o w n e r ]   =   d . u s e r n a m e   w h e r e   a c c e s s   =   ' p u b l i c '   g r o u p   b y   d . r e g i o n ,   i . [ o w n e r ]   o r d e r   b y   p u b l i c _ i t e m s   d e s c

 - -   N u m b e r   o f   i t e m s   b y   a c c e s s   l e v e l
 s e l e c t   a c c e s s ,   c o u n t ( * )   a s   i t e m s     f r o m   [ A G O L _ I T E M S ]   g r o u p   b y   a c c e s s

 - -   N u m b e r   o f   p u b l i c   i t e m s   w i t h   m i s s i n g   m e t a d a t a
 s e l e c t   d . r e g i o n ,   i . [ o w n e r ] ,   C O A L E S C E ( m d . c n t , 0 )   a s   m i s s i n g _ d e s c ,   C O A L E S C E ( m s . c n t , 0 )   a s   m i s s i n g _ s n i p ,   C O A L E S C E ( m i . c n t , 0 )   a s   m i s s i n g _ t h u m b ,   t m . c n t   a s   i t e m s _ w _ i s s u e s ,   c o u n t ( * )   a s   t o t a l _ i t e m s   f r o m   [ A G O L _ I T E M S ]   a s   i 
 l e f t   j o i n   D O M A I N I N F O   a s   d   o n   i . [ o w n e r ]   =   d . u s e r n a m e
 l e f t   j o i n   ( s e l e c t   [ o w n e r ] ,   c o u n t ( * )   a s   c n t   f r o m   [ A G O L _ I T E M S ]   w h e r e   a c c e s s   =   ' p u b l i c '   a n d   l e n _ d e s c   i s   n u l l   g r o u p   b y   [ o w n e r ] )   a s   m d   o n   m d . [ o w n e r ]   =   i . [ o w n e r ]
 l e f t   j o i n   ( s e l e c t   [ o w n e r ] ,   c o u n t ( * )   a s   c n t   f r o m   [ A G O L _ I T E M S ]   w h e r e   a c c e s s   =   ' p u b l i c '   a n d   l e n _ s n i p p e t   i s   n u l l   g r o u p   b y   [ o w n e r ] )   a s   m s   o n   m s . [ o w n e r ]   =   i . [ o w n e r ]
 l e f t   j o i n   ( s e l e c t   [ o w n e r ] ,   c o u n t ( * )   a s   c n t   f r o m   [ A G O L _ I T E M S ]   w h e r e   a c c e s s   =   ' p u b l i c '   a n d   t h u m b n a i l   i s   n u l l   a n d   t y p e   n o t   i n   ( ' I m a g e ' ,   ' P D F ' )   g r o u p   b y   [ o w n e r ] )   a s   m i   o n   m i . [ o w n e r ]   =   i . [ o w n e r ]
 l e f t   j o i n   ( s e l e c t   [ o w n e r ] ,   c o u n t ( * )   a s   c n t   f r o m   [ A G O L _ I T E M S ]   w h e r e   a c c e s s   =   ' p u b l i c '   a n d   ( l e n _ d e s c   i s   n u l l   o r   l e n _ s n i p p e t   i s   n u l l   o r   ( t h u m b n a i l   i s   n u l l   a n d   t y p e   n o t   i n   ( ' I m a g e ' ,   ' P D F ' ) ) )   g r o u p   b y   [ o w n e r ] )   a s   t m   o n   t m . [ o w n e r ]   =   i . [ o w n e r ]
 w h e r e   a c c e s s   =   ' p u b l i c '     a n d   t m . c n t   i s   n o t   n u l l   g r o u p   b y   d . r e g i o n ,   i . [ o w n e r ] ,   m d . c n t ,   m s . c n t ,   m i . c n t ,   t m . c n t   o r d e r   b y   d . r e g i o n ,   i . [ o w n e r ]

 - - n u m b e r   o f   p u b l i c   v i e w s   b y   u s e r
 s e l e c t   d . r e g i o n ,   i . [ o w n e r ] ,   s u m ( n u m V i e w s )   a s   [ v i e w s ]   f r o m   [ A G O L _ I T E M S ]   a s   i   l e f t   j o i n   D O M A I N I N F O   a s   d   o n   i . [ o w n e r ]   =   d . u s e r n a m e   w h e r e   a c c e s s   =   ' p u b l i c '   g r o u p   b y   d . r e g i o n ,   i . [ o w n e r ]   o r d e r   b y   [ v i e w s ]   d e s c

 - - d i s a b l e d   u s e r s 
 s e l e c t   d . r e g i o n ,   u . u s e r n a m e ,   u . e m a i l   f r o m   A G O L _ U S E R S   a s   u   l e f t   j o i n   D O M A I N I N F O   a s   d   o n   u . u s e r n a m e   =   d . u s e r n a m e   w h e r e   d i s a b l e d   =   ' T r u e '   o r d e r   b y   d . r e g i o n ,   u . u s e r n a m e

 - - d i s a b l e d   u s e r s   w i t h   n o   c o n t e n t   ( D E L E T E ? ) 
 s e l e c t   d . r e g i o n ,   u . u s e r n a m e ,   u . e m a i l   f r o m   A G O L _ U S E R S   a s   u   l e f t   j o i n   A G O L _ I T E M S   a s   i   o n   u . u s e r n a m e   =   i . o w n e r   l e f t   j o i n   D O M A I N I N F O   a s   d   o n   u . u s e r n a m e   =   d . u s e r n a m e   w h e r e   i . o w n e r   i s   n u l l   a n d   u . d i s a b l e d   =   ' T r u e '   o r d e r   b y   d . r e g i o n ,   u . u s e r n a m e

 - - d i s a b l e d   u s e r s   w i t h   c o n t e n t   ( m o v e   c o n t e n t ;   t h e n   d e l e t e ? )
 s e l e c t   d . r e g i o n ,   u . u s e r n a m e ,   u . e m a i l ,   c o u n t ( * )   a s   i t e m s   f r o m   A G O L _ U S E R S   a s   u   l e f t   j o i n   A G O L _ I T E M S   a s   i   o n   u . u s e r n a m e   =   i . o w n e r   l e f t   j o i n   D O M A I N I N F O   a s   d   o n   u . u s e r n a m e   =   d . u s e r n a m e   w h e r e   i . o w n e r   i s   n o t   n u l l   a n d   u . d i s a b l e d   =   ' T r u e '   g r o u p   b y   d . r e g i o n ,   u . u s e r n a m e ,   u . e m a i l   o r d e r   b y   d . r e g i o n ,   u . u s e r n a m e

 - - e n a b l e d   u s e r s   w i t h   n o   c o n t e n t   ( v i e w e r ? )
 s e l e c t   d . r e g i o n ,   u . u s e r n a m e ,   u . e m a i l   f r o m   A G O L _ U S E R S   a s   u   l e f t   j o i n   A G O L _ I T E M S   a s   i   o n   u . u s e r n a m e   =   i . o w n e r   l e f t   j o i n   D O M A I N I N F O   a s   d   o n   u . u s e r n a m e   =   d . u s e r n a m e   w h e r e   i . o w n e r   i s   n u l l   a n d   u . d i s a b l e d   =   ' F a l s e '   o r d e r   b y   d . r e g i o n ,   u . u s e r n a m e

 - - e n a b l e d   u s e r s   w i t h   c o n t e n t   ( c r e a t o r s ) 
 s e l e c t   d . r e g i o n ,   u . u s e r n a m e ,   u . e m a i l ,   c o u n t ( * )   a s   i t e m s   f r o m   A G O L _ U S E R S   a s   u   l e f t   j o i n   A G O L _ I T E M S   a s   i   o n   u . u s e r n a m e   =   i . o w n e r   l e f t   j o i n   D O M A I N I N F O   a s   d   o n   u . u s e r n a m e   =   d . u s e r n a m e   w h e r e   i . o w n e r   i s   n o t   n u l l   a n d   u . d i s a b l e d   =   ' F a l s e '   g r o u p   b y   d . r e g i o n ,   u . u s e r n a m e ,   u . e m a i l   o r d e r   b y   d . r e g i o n ,   u . u s e r n a m e

 - - e n a b l e d   u s e r s   w i t h   n o   c o n t e n t   a n d   n o  A D   r e c o r d   ( D E L E T E ? ) 
 s e l e c t   d . r e g i o n ,   u . u s e r n a m e ,   u . e m a i l   f r o m   A G O L _ U S E R S   a s   u   l e f t   j o i n   A G O L _ I T E M S   a s   i   o n   u . u s e r n a m e   =   i . o w n e r   l e f t   j o i n   D O M A I N I N F O   a s   d   o n   u . u s e r n a m e   =   d . u s e r n a m e   w h e r e   i . o w n e r   i s   n u l l   a n d   d . d o m a i n _ c n   i s   n u l l   a n d   u . d i s a b l e d   =   ' F a l s e '   o r d e r   b y   d . r e g i o n ,   u . u s e r n a m e

 - - e n a b l e d   u s e r s   w i t h   c o n t e n t   a n d   n o   A D   r e c o r d   ( d i s a b l e   o r   f i x   a c c o u n t ) 
 s e l e c t   d . r e g i o n ,   u . u s e r n a m e ,   u . e m a i l ,   c o u n t ( * )   a s   i t e m s     f r o m   A G O L _ U S E R S   a s   u   l e f t   j o i n   A G O L _ I T E M S   a s   i   o n   u . u s e r n a m e   =   i . o w n e r   l e f t   j o i n   D O M A I N I N F O   a s   d   o n   u . u s e r n a m e   =   d . u s e r n a m e   w h e r e   i . o w n e r   i s   n o t   n u l l   a n d   d . d o m a i n _ c n   i s   n u l l     a n d   u . d i s a b l e d   =   ' F a l s e '   g r o u p   b y   d . r e g i o n ,   u . u s e r n a m e ,   u . e m a i l   o r d e r   b y   d . r e g i o n ,   u . u s e r n a m e

 - - d u p l i c a t e s 
 s e l e c t   d . r e g i o n ,   u . u s e r n a m e ,   d . e m a i l ,   i . c n t   a s   i t e m s   f r o m   A G O L _ U S E R S   a s   u   l e f t   j o i n   D O M A I N I N F O   a s   d   o n   u . u s e r n a m e   =   d . u s e r n a m e   l e f t   j o i n   ( s e l e c t   o w n e r ,   c o u n t ( * )   a s   c n t   f r o m   A G O L _ I T E M S   g r o u p   b y   o w n e r )   a s   i   o n   i . o w n e r   =   u . u s e r n a m e   w h e r e     d . d o m a i n _ c n   i n   ( s e l e c t   d o m a i n _ c n   f r o m   D O M A I N I N F O   w h e r e   d o m a i n _ c n   i s   n o t   n u l l   g r o u p   b y   d o m a i n _ c n   h a v i n g   c o u n t ( * )   >   1 )   o r d e r   b y   d . r e g i o n ,   d . e m a i l ,   u . u s e r n a m e
