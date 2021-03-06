/****** Object:  StoredProcedure [dbo].[BSUP_INSERT_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSUP_INSERT_S1] (
 @Ad_Begin_DATE               	DATE,
 @An_Case_IDNO                	NUMERIC(6, 0),
 @An_EventGlobalBeginSeq_NUMB	NUMERIC(19, 0),
 @Ac_TypeAction_CODE          	CHAR(1),
 @Ad_End_DATE                 	DATE,
 @Ac_Reason_CODE              	CHAR(2),
 @An_EventGlobalEndSeq_NUMB   	NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : BSUP_INSERT_S1
  *     DESCRIPTION       : Insert Billing Supression details.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 03-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Current_DATE	DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
    	  @Ld_High_DATE 	DATE = '12/31/9999';

  INSERT BSUP_Y1
         (Case_IDNO,
          TypeAction_CODE,
          Begin_DATE,
          End_DATE,
          Reason_CODE,
          BeginValidity_DATE,
          EndValidity_DATE,
          EventGlobalBeginSeq_NUMB,
          EventGlobalEndSeq_NUMB)
  VALUES ( @An_Case_IDNO,
           @Ac_TypeAction_CODE,
           @Ad_Begin_DATE,
           @Ad_End_DATE,
           @Ac_Reason_CODE,
           @Ld_Current_DATE,
           @Ld_High_DATE ,
           @An_EventGlobalBeginSeq_NUMB,
           @An_EventGlobalEndSeq_NUMB);
 END; --END OF BSUP_INSERT_S1 


GO
