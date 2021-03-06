/****** Object:  StoredProcedure [dbo].[NOTE_RETRIEVE_S20]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NOTE_RETRIEVE_S20] (
 @An_Topic_IDNO                 NUMERIC(10, 0),
 @As_DescriptionNote_TEXT       VARCHAR(4000)  OUTPUT
 )
AS
 /*                                                                                              
  *     PROCEDURE NAME    : NOTE_RETRIEVE_S20                                                    
  *     DESCRIPTION       : Retrieve Description for a Topic Idno and Post Idno is 1.
  *     DEVELOPED BY      : IMP Team                                                           
  *     DEVELOPED ON      : 16-MAY-2012                                                  
  *     MODIFIED BY       :                                                                      
  *     MODIFIED ON       :                                                                      
  *     VERSION NO        : 1                                                                    
 */
 BEGIN
  SELECT @As_DescriptionNote_TEXT = NULL;     

  DECLARE @Li_One_NUMB  SMALLINT = 1,
          @Ld_High_DATE DATE = '12/31/9999';

  SELECT @As_DescriptionNote_TEXT = N.DescriptionNote_TEXT        
    FROM NOTE_Y1 N
   WHERE N.Topic_IDNO = @An_Topic_IDNO
     AND N.Post_IDNO = @Li_One_NUMB
     AND N.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF NOTE_RETRIEVE_S20                                                                                           ;


GO
