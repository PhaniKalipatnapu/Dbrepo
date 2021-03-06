/****** Object:  StoredProcedure [dbo].[MSSN_RETRIEVE_S19]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MSSN_RETRIEVE_S19](
 @An_MemberSsn_NUMB NUMERIC(9, 0),
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ai_Count_QNTY     INT OUTPUT
 )
AS
 /*                                                                                                                                                  
 *     PROCEDURE NAME    : MSSN_RETRIEVE_S19                                                                                                         
  *     DESCRIPTION       : Retrieve Member SSN record count for a Member ID, Members SSN and Verification Code Received for SSN Verification is Bad.
  *     DEVELOPED BY      : IMP Team                                                                                                               
  *     DEVELOPED ON      : 02-MAR-2011                                                                                                              
  *     MODIFIED BY       :                                                                                                                          
  *     MODIFIED ON       :                                                                                                                          
  *     VERSION NO        : 1                                                                                                                        
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_VerificationStatusBad_CODE CHAR(1) = 'B',
          @Ld_High_DATE                  DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM MSSN_Y1 M
   WHERE M.MemberMci_IDNO = @An_MemberMci_IDNO
     AND M.MemberSsn_NUMB = @An_MemberSsn_NUMB
     AND M.Enumeration_CODE <> @Lc_VerificationStatusBad_CODE
     AND M.EndValidity_DATE = @Ld_High_DATE;
 END; --End of MSSN_RETRIEVE_S19


GO
