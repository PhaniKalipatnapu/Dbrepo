/****** Object:  StoredProcedure [dbo].[OFIC_RETRIEVE_S27]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OFIC_RETRIEVE_S27] (
 @An_SignedOnOffice_IDNO	NUMERIC(3, 0),
 @Ac_SignedOnWorker_ID  	CHAR(30),
 @An_OfficeOut_IDNO     	NUMERIC(3, 0) OUTPUT,
 @An_County_IDNO        	NUMERIC(3, 0) OUTPUT,
 @An_OtherParty_IDNO    	NUMERIC(9, 0) OUTPUT,
 @Ad_StartOffice_DTTM   	DATETIME2 OUTPUT,
 @Ad_CloseOffice_DTTM   	DATETIME2 OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : OFIC_RETRIEVE_S27  
  *     DESCRIPTION       : Retrieve the office,county,otherparty details and start,close office time  for worker 
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 24-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SELECT @Ad_CloseOffice_DTTM = NULL,
         @Ad_StartOffice_DTTM = NULL,
         @An_County_IDNO = NULL,
         @An_OfficeOut_IDNO = NULL,
         @An_OtherParty_IDNO = NULL;

  DECLARE @Ld_High_DATE    DATE = '12/31/9999',
          @Ld_Current_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT @An_OfficeOut_IDNO = a.Office_IDNO,
         @An_County_IDNO = d.County_IDNO,
         @An_OtherParty_IDNO = d.OtherParty_IDNO,
         @Ad_StartOffice_DTTM = d.StartOffice_DTTM,
         @Ad_CloseOffice_DTTM = d.CloseOffice_DTTM
    FROM UASM_Y1 a
         JOIN OFIC_Y1 d
          ON a.Office_IDNO = d.Office_IDNO
   WHERE a.Worker_ID = @Ac_SignedOnWorker_ID
     AND a.Office_IDNO = @An_SignedOnOffice_IDNO
     AND @Ld_Current_DATE BETWEEN a.Effective_DATE AND a.Expire_DATE
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND d.EndValidity_DATE = @Ld_High_DATE;
 END; --End Of OFIC_RETRIEVE_S27 



GO
