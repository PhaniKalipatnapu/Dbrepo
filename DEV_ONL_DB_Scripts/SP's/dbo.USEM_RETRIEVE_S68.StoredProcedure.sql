/****** Object:  StoredProcedure [dbo].[USEM_RETRIEVE_S68]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USEM_RETRIEVE_S68] 
	(
 	   @An_County_IDNO   NUMERIC(3, 0)
 	)
AS
 /*
  *     PROCEDURE NAME    : USEM_RETRIEVE_S
  *     DESCRIPTION       : Retrieves the user master information.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 03/22/2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN        

  DECLARE @Lc_Role_ID		  CHAR (10) = 'RS027',
		  @Ld_High_DATE       DATE = '12/31/9999',
          @Ld_Systemdate_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT U.Worker_ID
    FROM USEM_Y1 U
   WHERE U.EndValidity_DATE = @Ld_High_DATE
     AND U.EndEmployment_DATE >= @Ld_Systemdate_DATE
     AND U.BeginEmployment_DATE <= @Ld_Systemdate_DATE
     AND EXISTS (SELECT U1.Worker_ID
                   FROM USRL_Y1 U1
                  WHERE U.Worker_ID = U1.Worker_ID		    
                    AND U1.Expire_DATE >= @Ld_Systemdate_DATE
                    AND U1.Effective_DATE <= @Ld_Systemdate_DATE
                    AND U1.EndValidity_DATE = @Ld_High_DATE
                    AND U1.Role_ID = @Lc_Role_ID
					AND U1.Office_IDNO IN (SELECT O.Office_IDNO 
											FROM OFIC_Y1 O 
											WHERE O.County_IDNO = @An_County_IDNO));

 END; --End Of USEM_RETRIEVE_S68

GO
