/****** Object:  StoredProcedure [dbo].[APCS_RETRIEVE_S27]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCS_RETRIEVE_S27](
	 @An_Application_IDNO 	 NUMERIC(15),
	 @An_TransHeader_IDNO    NUMERIC(12),  
	 @Ac_StateFips_CODE      CHAR(2),  
	 @Ad_Transaction_DATE    DATE,    
	 @Ac_Exists_INDC         CHAR(1) OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : APCS_RETRIEVE_S27
  *     DESCRIPTION       : sets the ICOR indicator to 'N' if records exists for the given unique application ID, unique transaction header Id, Local-FIPs-State code, and transaction date where case relation member type is not empty and enddate validity is highdate.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_Yes_INDC       CHAR(1)= 'Y',
  		  @Lc_No_INDC        CHAR(1)= 'N',
          @Lc_Space_TEXT     CHAR(1)= ' ',
          @Ld_High_DATE 	 DATE 	= '12/31/9999' ;

  SET @Ac_Exists_INDC = @Lc_No_INDC;

  SELECT @Ac_Exists_INDC = @Lc_Yes_INDC
    FROM APCS_Y1 AC
   WHERE AC.Application_IDNO = @An_Application_IDNO
     AND AC.TransHeader_IDNO = @An_TransHeader_IDNO  
	 AND AC.StateFips_CODE = @Ac_StateFips_CODE  
     AND AC.Transaction_DATE = @Ad_Transaction_DATE  
     AND AC.TypeCase_CODE   <> @Lc_Space_TEXT
     AND AC.EndValidity_DATE = @Ld_High_DATE;
 END; --End of APCS_RETRIEVE_S27


GO
