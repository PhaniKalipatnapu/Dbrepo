/****** Object:  StoredProcedure [dbo].[POBL_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[POBL_RETRIEVE_S7] (  
 @An_Case_IDNO  NUMERIC(6,0), 
 @Ac_Exists_INDC      CHAR(1)         OUTPUT  
    )  
AS  
  
/*  
 *     PROCEDURE NAME    : POBL_RETRIEVE_S7  
 *     DESCRIPTION       : Check whether Pending Obligation is exists for the Pending Support Order record.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 11/10/2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1.0  
 */  
BEGIN 
SET @Ac_Exists_INDC   =  'N';
DECLARE
		@Lc_ProcessL_CODE	CHAR(1) = 'L';
SELECT @Ac_Exists_INDC='Y' 
  FROM POBL_Y1 o,
       PSRD_Y1 s
 WHERE s.Case_IDNO=@An_Case_IDNO
   AND o.Record_NUMB=(SELECT MIN(Record_NUMB)
                        FROM PSRD_Y1
                       WHERE Case_IDNO=@An_Case_IDNO
                         AND Process_CODE=@Lc_ProcessL_CODE
                        )
   AND o.Process_CODE=@Lc_ProcessL_CODE
   AND s.Process_CODE=@Lc_ProcessL_CODE;
 END;--END OF POBL_RETRIEVE_S7
GO
