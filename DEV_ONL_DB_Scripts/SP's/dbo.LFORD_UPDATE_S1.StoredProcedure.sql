/****** Object:  StoredProcedure [dbo].[LFORD_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LFORD_UPDATE_S1] (
 @An_Case_IDNO NUMERIC(6, 0),
 @Ac_File_ID   CHAR(10),
 @An_CpMci_IDNO NUMERIC(10, 0),
 @An_NcpMci_IDNO NUMERIC(10, 0)
 )
AS
 /*    
  *     PROCEDURE NAME    : LFORD_UPDATE_S1
  *     DESCRIPTION       : Update New Case IdNo to Referral Source FAMIS Details.
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 11-APR-2012
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  DECLARE @Li_Zero_NUMB				SMALLINT = 0,
		  @Lc_No_INDC               CHAR(1) = 'N',
	      @Ln_RowsAffected_NUMB     NUMERIC(10);

  UPDATE LFORD_Y1
	 SET Case_IDNO = @An_Case_IDNO,
	     ObligeeMCI_IDNO = @An_CpMci_IDNO,
		 ObligorMci_IDNO = @An_NcpMci_IDNO
   WHERE FamilyCourtFile_ID = @Ac_File_ID
     AND Case_IDNO = @Li_Zero_NUMB
     AND Process_INDC = @Lc_No_INDC;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END -- End Of LFORD_UPDATE_S1  

GO
