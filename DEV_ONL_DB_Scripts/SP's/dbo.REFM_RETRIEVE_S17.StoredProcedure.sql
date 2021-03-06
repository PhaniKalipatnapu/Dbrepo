/****** Object:  StoredProcedure [dbo].[REFM_RETRIEVE_S17]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[REFM_RETRIEVE_S17] (
 @Ac_Table_ID                 CHAR(4),
 @Ac_TableSub_ID              CHAR(4),
 @Ac_Value_CODE               CHAR(10),
 @As_DescriptionValue_TEXT 	  VARCHAR(70) OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : REFM_RETRIEVE_S17
  *     DESCRIPTION       : Retrieve Transaction Event Sequence for a Table Idno, Sub Table Idno, and Value Code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-AUG-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
  */
 BEGIN
 
  SELECT @As_DescriptionValue_TEXT = NULL,
  		 @An_TransactionEventSeq_NUMB = NULL;

  SELECT @As_DescriptionValue_TEXT = r.DescriptionValue_TEXT,
  		 @An_TransactionEventSeq_NUMB = r.TransactionEventSeq_NUMB
    FROM REFM_Y1 r
   WHERE r.Table_ID = @Ac_Table_ID
     AND r.TableSub_ID = @Ac_TableSub_ID
     AND r.Value_CODE = @Ac_Value_CODE;
 END; --End Of REFM_RETRIEVE_S17

GO
