/****** Object:  StoredProcedure [dbo].[NOTE_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NOTE_RETRIEVE_S13] (
 @An_Case_IDNO                  NUMERIC(6, 0),
 @An_Topic_IDNO                 NUMERIC(10, 0),
 @As_DescriptionNote_TEXT       VARCHAR(4000)  OUTPUT,
 @An_TransactionEventSeq_NUMB   NUMERIC(19, 0) OUTPUT
 )
AS
 /*                                                                                              
  *     PROCEDURE NAME    : NOTE_RETRIEVE_S13                                                     
  *     DESCRIPTION       : Retrieve Description for a Case Idno, Topic Idno, and Post Idno is 1.
  *     DEVELOPED BY      : IMP Team                                                           
  *     DEVELOPED ON      : 02-SEP-2011                                                      
  *     MODIFIED BY       :                                                                      
  *     MODIFIED ON       :                                                                      
  *     VERSION NO        : 1                                                                    
 */
 BEGIN
  SELECT @As_DescriptionNote_TEXT = NULL,
         @An_TransactionEventSeq_NUMB =NULL;

  DECLARE @Li_One_NUMB  SMALLINT = 1,
          @Ld_High_DATE DATE = '12/31/9999';

  SELECT @As_DescriptionNote_TEXT = N.DescriptionNote_TEXT ,
         @An_TransactionEventSeq_NUMB = N.TransactionEventSeq_NUMB
    FROM NOTE_Y1 N
   WHERE N.Case_IDNO = @An_Case_IDNO
     AND N.Topic_IDNO = @An_Topic_IDNO
     AND N.Post_IDNO = @Li_One_NUMB
     AND N.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF NOTE_RETRIEVE_S13                                                                                           ;


GO
