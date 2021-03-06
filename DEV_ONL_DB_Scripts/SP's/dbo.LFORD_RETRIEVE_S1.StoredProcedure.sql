/****** Object:  StoredProcedure [dbo].[LFORD_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LFORD_RETRIEVE_S1](
	 @Ac_File_ID   CHAR(10),
	 @Ac_Exists_INDC        CHAR(1) OUTPUT
)
AS
 /*
 *     PROCEDURE NAME    : LFORD_RETRIEVE_S1
  *     DESCRIPTION       : To Check the Referral Source FAMIS Exiting
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-APR-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
   DECLARE @Li_Zero_NUMB				   SMALLINT = 0,		   
   		   @Lc_No_INDC                     CHAR(1) = 'N',
   		   @Lc_Yes_INDC					   CHAR(1) = 'Y';
          
   SET @Ac_Exists_INDC = @Lc_No_INDC;

  SELECT @Ac_Exists_INDC = @Lc_Yes_INDC
    FROM LFORD_Y1 LF
  WHERE LF.FamilyCourtFile_ID = @Ac_File_ID
  AND LF.Case_IDNO = @Li_Zero_NUMB
  AND LF.Process_INDC = @Lc_No_INDC;
  
 END; --End of LFORD_RETRIEVE_S1


GO
