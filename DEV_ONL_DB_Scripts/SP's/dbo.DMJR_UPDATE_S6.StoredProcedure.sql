/****** Object:  StoredProcedure [dbo].[DMJR_UPDATE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_UPDATE_S6] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @An_Forum_IDNO         NUMERIC(10, 0),
 @An_MajorIntSeq_NUMB   NUMERIC(5, 0),
 @Ac_ActivityMinor_CODE CHAR(5),
 @Ac_SignedOnWorker_ID  CHAR(30)
 )
AS
 /*  
  *     PROCEDURE NAME    : DMJR_UPDATE_S6  
  *     DESCRIPTION       : Update Start & End Exemption date, Begining Validity to System date, Worker ID, Effective date-time at which record was inserted/modified and Unique Sequence Number for a Case ID, Remedy Status is Exemption, Activity Major Code 
 							and Start & End Exemption date is between System date..  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 11-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);
  DECLARE @Li_One_NUMB        SMALLINT = 1,
          @Ld_Systemdate_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE       DATE = '12/31/9999';

  UPDATE DMJR_Y1
     SET TotalTopics_QNTY = TotalTopics_QNTY + @Li_One_NUMB,
         PostLastPoster_IDNO = @Li_One_NUMB,
         UserLastPoster_ID = @Ac_SignedOnWorker_ID,
         SubjectLastPoster_TEXT = (SELECT A.DescriptionActivity_TEXT
                                     FROM AMNR_Y1 A
                                    WHERE A.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
                                      AND A.EndValidity_DATE = @Ld_High_DATE),
         LastPost_DTTM = @Ld_Systemdate_DTTM
   WHERE Case_IDNO = @An_Case_IDNO
     AND MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
     AND Forum_IDNO = @An_Forum_IDNO;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End Of DMJR_UPDATE_S6


GO
