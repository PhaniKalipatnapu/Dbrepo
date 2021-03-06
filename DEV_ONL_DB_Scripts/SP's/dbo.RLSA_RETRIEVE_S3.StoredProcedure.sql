/****** Object:  StoredProcedure [dbo].[RLSA_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/*  
  *     PROCEDURE NAME    : RLSA_RETRIEVE_S3  
  *     DESCRIPTION       : Retrieve the Role Screen Access details for a Role Id, Screen Id, Screen Function.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 10/11/2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */  
CREATE PROCEDURE [dbo].[RLSA_RETRIEVE_S3](  
 @Ac_Screen_ID    CHAR(4) = NULL,  
 @Ac_Role_ID      CHAR(10) = NULL,  
 @Ai_RowFrom_NUMB INT= 1,  
 @Ai_RowTo_NUMB   INT = 10 
 )  
AS  
 BEGIN  
  DECLARE @Ld_High_DATE DATE = '12/31/9999';  
  
  WITH Rlsa_CTE ( Role_ID, Screen_ID, ScreenFunction_CODE, Access_INDC, TransactionEventSeq_NUMB, Row_NUMB, RowCount_NUMB)  
       AS (SELECT Y.Role_ID,  
                  Y.Screen_ID,  
                  Y.ScreenFunction_CODE,  
                  Y.Access_INDC,  
                  Y.TransactionEventSeq_NUMB,  
                  Y.Row_NUMB,  
                  Y.RowCount_NUMB  
             FROM (SELECT X.Role_ID,  
                          X.Screen_ID,  
                          X.ScreenFunction_CODE,  
                          X.Access_INDC,  
                          X.TransactionEventSeq_NUMB,  
                          X.Row_NUMB,  
                          X.RowCount_NUMB  
                     FROM (SELECT a.Role_ID,  
                                  a.Screen_ID,  
                                  a.ScreenFunction_CODE,  
                                  a.Access_INDC,  
                                  a.TransactionEventSeq_NUMB,  
                                  ROW_NUMBER() OVER(ORDER BY a.Screen_ID, a.Role_ID) AS Row_NUMB,  
                                  COUNT(1) OVER() AS RowCount_NUMB  
                             FROM RLSA_Y1 a  
                            WHERE a.Screen_ID = ISNULL(@Ac_Screen_ID, a.Screen_ID)  
                              AND a.Role_ID = ISNULL(@Ac_Role_ID, a.Role_ID)  
                              AND a.EndValidity_DATE = @Ld_High_DATE) X  
                    WHERE X.Row_NUMB <= @Ai_RowTo_NUMB) Y  
            WHERE Y.Row_NUMB >= @Ai_RowFrom_NUMB)  
  SELECT RL.Role_ID,  
         R.Role_NAME,  
         RL.Screen_ID,  
         RL.ScreenFunction_CODE,  
         SFN.ScreenFunction_NAME,  
         SFN.AccessView_INDC,  
         SFN.AccessAdd_INDC,  
         SFN.AccessModify_INDC,  
         SFN.AccessDelete_INDC,  
         RL.Access_INDC,  
         R.StateRole_INDC,  
         SFN.NoPosition_IDNO,  
         RL.TransactionEventSeq_NUMB,  
         R.TransactionEventSeq_NUMB AS RoleTransactionEventSeq_NUMB,
         RL.RowCount_NUMB  
    FROM Rlsa_CTE RL  
         JOIN SCFN_Y1 SFN  
          ON RL.Screen_ID = SFN.Screen_ID  
             AND RL.ScreenFunction_CODE = SFN.ScreenFunction_CODE  
         JOIN ROLE_Y1 R  
          ON RL.Role_ID = R.Role_ID  
   WHERE SFN.EndValidity_DATE = @Ld_High_DATE  
     AND R.EndValidity_DATE = @Ld_High_DATE  
   ORDER BY RowCount_NUMB;  
 END  
  
GO
