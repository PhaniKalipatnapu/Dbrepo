/****** Object:  StoredProcedure [dbo].[FDEM_RETRIEVE_S27]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FDEM_RETRIEVE_S27] (
 @An_Case_IDNO		NUMERIC(6, 0),
 @Ac_File_ID		CHAR(10),
 @An_Petition_IDNO	NUMERIC(7, 0),
 @Ac_Exists_INDC	CHAR(1)		OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : FDEM_RETRIEVE_S27  
  *     DESCRIPTION       : checks the Petition idno,case idno, file id  are exists  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 16-oct-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE  
	@Lc_Yes_INDC	CHAR(1) = 'Y',
	@Lc_No_INDC		CHAR(1) = 'N',
	@Ld_High_DATE	DATE	= '12/31/9999';

SET
	@Ac_Exists_INDC = @Lc_No_INDC ;

  SELECT @Ac_Exists_INDC = @Lc_Yes_INDC
    FROM FDEM_Y1 F
   WHERE F.Case_IDNO = @An_Case_IDNO
     AND F.File_ID = @Ac_File_ID
     AND F.Petition_IDNO = ISNULL (@An_Petition_IDNO,F.Petition_IDNO)
     AND F.EndValidity_DATE = @Ld_High_DATE;
 END; -- END OF FDEM_RETRIEVE_S27  



GO
