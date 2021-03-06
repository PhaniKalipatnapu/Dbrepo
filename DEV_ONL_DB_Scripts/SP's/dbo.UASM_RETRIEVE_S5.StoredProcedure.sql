/****** Object:  StoredProcedure [dbo].[UASM_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UASM_RETRIEVE_S5] (
 @Ac_SignedOnWorker_ID CHAR(30)
 )
AS
 /*                                                                      
  *     PROCEDURE NAME   : UASM_RETRIEVE_S5                              
  *     DESCRIPTION      : Retrieve the office to which the user is assigned to work.                       
  *     DEVELOPED BY     : IMP Team                         
  *     DEVELOPED ON     : 02-AUG-2011                                   
  *     MODIFIED BY      :                                               
  *     MODIFIED ON      :                                               
  *     VERSION NO       : 1                                             
 */
 BEGIN
  DECLARE @Ld_High_DATE       DATE = '12/31/9999',
          @Ld_Systemdate_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT A.Office_IDNO
    FROM UASM_Y1 A
         JOIN OFIC_Y1 B
          ON B.Office_IDNO = A.Office_IDNO
		 JOIN USEM_Y1 U
          ON U.Worker_ID = A.Worker_ID
   WHERE A.Worker_ID = @Ac_SignedOnWorker_ID
	 AND A.Effective_DATE <= @Ld_Systemdate_DATE
     AND A.EndValidity_DATE = @Ld_High_DATE
     AND A.Expire_DATE > @Ld_Systemdate_DATE
     AND B.EndValidity_DATE = @Ld_High_DATE
	 AND U.BeginEmployment_DATE <= @Ld_Systemdate_DATE
     AND U.EndValidity_DATE = @Ld_High_DATE;
 END; --End Of UASM_RETRIEVE_S5                                                                   

GO
