/****** Object:  StoredProcedure [dbo].[DCRS_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DCRS_RETRIEVE_S3] (
 @Ac_CheckRecipient_ID        CHAR(10),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0) OUTPUT,
 @Ad_Status_DATE              DATE OUTPUT,
 @Ac_Status_CODE              CHAR(1) OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : DCRS_RETRIEVE_S3
  *     DESCRIPTION       : Retrieves event begin sequence, status date & status code for the given check recipient ID.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @An_EventGlobalBeginSeq_NUMB = NULL,
         @Ad_Status_DATE = '01/01/0001',
         @Ac_Status_CODE = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_EventGlobalBeginSeq_NUMB = d.EventGlobalBeginSeq_NUMB,
         @Ad_Status_DATE = d.Status_DATE,
         @Ac_Status_CODE = d.Status_CODE
    FROM DCRS_Y1 d
   WHERE d.CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND d.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of DCRS_RETRIEVE_S3

GO
